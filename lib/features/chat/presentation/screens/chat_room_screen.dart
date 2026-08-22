import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import '../../domain/entities/chat_entities.dart';

class ChatRoomScreen extends StatefulWidget {
  final int? chatId;
  const ChatRoomScreen({super.key, this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  static const Color _navy = Color(0xFF1400FF);
  static const Color _yellow = Color(0xFFFFD700);
  static const Color _chatBg = Color(0xFFF5F5F7);

  late final int chatId;
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId ?? Get.arguments as int;
    controller = Get.find<ChatController>();
    controller.startMessagePolling(chatId);
  }

  @override
  void dispose() {
    controller.stopMessagePolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _chatBg,
      body: Column(
        children: [
          _buildAppBar(context),
          _buildProductContext(),
          Expanded(
            child: Stack(
              children: [
                _buildWatermark(),
                Obx(() {
                  if (controller.isLoadingMessages.value &&
                      controller.rxMessages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF003BFF),
                        ),
                      ),
                    );
                  }

                  if (controller.rxMessages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No messages here yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Say hello to start the conversation!',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemBuilder: (context, index) {
                      final msg = controller.rxMessages[index];
                      if (msg.isMe) {
                        return _OutgoingBubble(message: msg);
                      } else {
                        return _IncomingBubble(message: msg);
                      }
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: controller.rxMessages.length,
                  );
                }),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      color: _navy,
      padding: EdgeInsets.fromLTRB(4, top + 4, 8, 12),
      child: Obx(() {
        final info = controller.rxChatInfo.value;
        final peerName = info?.peer.name.isNotEmpty == true
            ? info!.peer.name
            : 'Seller';
        final peerRole = info != null
            ? (info.myRole == 'buyer' ? 'Seller' : 'Buyer').toUpperCase()
            : 'PEER';

        return Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF94A3B8),
                  backgroundImage: info != null && info.peer.photo.isNotEmpty
                      ? NetworkImage(info.peer.photo)
                      : null,
                  child: info == null || info.peer.photo.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: _navy, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    peerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ONLINE • $peerRole',
                    style: const TextStyle(
                      color: Color(0xFFB8C5FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(
            //     Icons.videocam_outlined,
            //     color: Colors.white,
            //     size: 26,
            //   ),
            // ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(
            //     Icons.call_outlined,
            //     color: Colors.white,
            //     size: 24,
            //   ),
            // ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductContext() {
    return Obx(() {
      final info = controller.rxChatInfo.value;
      if (info == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        // shadowColor: Colors.black12,
        // elevation: 1.5,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
                image: info.product.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(info.product.image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: info.product.image.isEmpty
                  ? const Icon(Icons.shopping_bag_outlined, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${info.product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF003BFF),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Enquiry',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWatermark() {
    return IgnorePointer(
      child: Center(
        child: Transform.rotate(
          angle: -0.35,
          child: Opacity(
            opacity: 0.05,
            child: const Text(
              'Rozgar',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w600,
                color: _navy,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Material(
      color: const Color(0xFFECECEF),
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => controller.pickAndSendFile(chatId),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add, color: Color(0xFF64748B), size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E6),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.messageDraftController,
                          minLines: 1,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Draft a response...',
                            hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Color(0xFF8E8E93),
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                final isSending = controller.isSendingMessage.value;
                return Material(
                  color: isSending ? Colors.grey : _yellow,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: isSending
                        ? null
                        : () => controller.sendMessage(
                            chatId,
                            controller.messageDraftController.text,
                          ),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: isSending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black87,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final ChatMessage message;
  const _IncomingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final hasFile = message.fileUrl != null && message.fileUrl!.isNotEmpty;
    final isPdf = hasFile && message.fileUrl!.toLowerCase().endsWith('.pdf');

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                14,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1400FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasFile) ...[
                            if (isPdf)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      message.fileName ?? 'Document.pdf',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  message.fileUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            message.message,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              '${message.time} • ${message.date}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  final ChatMessage message;
  const _OutgoingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final hasFile = message.fileUrl != null && message.fileUrl!.isNotEmpty;
    final isPdf = hasFile && message.fileUrl!.toLowerCase().endsWith('.pdf');

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF001A99),
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomRight: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF001A99).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasFile) ...[
                  if (isPdf)
                    Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message.fileName ?? 'Document.pdf',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.fileUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.time} • ${message.date}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 15,
                  color: message.isRead == 1
                      ? const Color(0xFF38BDF8)
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
