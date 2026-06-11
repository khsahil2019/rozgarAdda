import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repository/chat_repository.dart';
import '../screens/chat_room_screen.dart';

class ChatController extends GetxController {
  final ChatRepository repository;

  ChatController({required this.repository});

  final rxChats = <ChatEnquiry>[].obs;
  final rxMessages = <ChatMessage>[].obs;
  final rxChatInfo = Rxn<ChatInfo>();

  final isLoadingChats = false.obs;
  final isLoadingMessages = false.obs;
  final isSendingMessage = false.obs;

  final activeChatId = RxnInt();
  final messageDraftController = TextEditingController();
  final scrollController = ScrollController();

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchEnquiries();
  }

  @override
  void onClose() {
    stopMessagePolling();
    messageDraftController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchEnquiries() async {
    try {
      isLoadingChats.value = true;
      final res = await repository.getMyEnquiries();
      res.fold(
        (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
        (chats) => rxChats.assignAll(chats),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingChats.value = false;
    }
  }

  Future<void> initiateChat(int sellId) async {
    try {
      Get.showOverlay(
        asyncFunction: () async {
          final res = await repository.startChat(sellId);
          res.fold(
            (failure) {
              Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
            },
            (chatId) {
              Get.to(() => const ChatRoomScreen(), arguments: chatId);
            },
          );
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003BFF)),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchMessages(int chatId, {bool showLoading = false}) async {
    if (showLoading) isLoadingMessages.value = true;
    try {
      final res = await repository.getChatMessages(chatId);
      res.fold(
        (failure) {
          if (showLoading) {
            Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
          }
        },
        (details) {
          final isFirstLoad = rxMessages.isEmpty;
          rxMessages.assignAll(details.messages);
          rxChatInfo.value = details.chatInfo;
          if (isFirstLoad || showLoading) {
            _scrollToBottom();
          }
        },
      );
    } catch (e) {
      if (showLoading) {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (showLoading) isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage(int chatId, String message, {String? filePath}) async {
    if (message.trim().isEmpty && filePath == null) return;
    try {
      isSendingMessage.value = true;
      final res = await repository.sendChatMessage(chatId, message, filePath: filePath);
      res.fold(
        (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
        (msg) {
          rxMessages.add(msg);
          messageDraftController.clear();
          _scrollToBottom();
          
          // Local update in the active chat list
          final index = rxChats.indexWhere((c) => c.id == chatId);
          if (index != -1) {
            final old = rxChats[index];
            rxChats[index] = ChatEnquiry(
              id: old.id,
              sellId: old.sellId,
              productTitle: old.productTitle,
              productPrice: old.productPrice,
              productImage: old.productImage,
              peerName: old.peerName,
              peerPhone: old.peerPhone,
              peerEmail: old.peerEmail,
              peerAddress: old.peerAddress,
              peerPhoto: old.peerPhoto,
              myUnread: old.myUnread,
              lastMessage: msg.message,
              lastAt: 'Just now',
            );
          }
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingMessage.value = false;
    }
  }

  void startMessagePolling(int chatId) {
    activeChatId.value = chatId;
    stopMessagePolling();
    fetchMessages(chatId, showLoading: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      fetchMessages(chatId);
    });
  }

  void stopMessagePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    activeChatId.value = null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickAndSendFile(int chatId) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await sendMessage(chatId, '[Attachment]', filePath: path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
