import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'chat_room_screen.dart';
import '../../domain/entities/chat_entities.dart';

class ChatUserListScreen extends GetView<ChatController> {
  const ChatUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh chats whenever we load this screen
    controller.fetchEnquiries();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 14),
            _SearchBox(controller: controller),
            const SizedBox(height: 16),
            const _CategoryTabs(),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingChats.value && controller.rxChats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003BFF)),
                    ),
                  );
                }

                if (controller.rxChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No enquiries yet.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchEnquiries(),
                  color: const Color(0xFF003BFF),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final chat = controller.rxChats[index];
                      return InkWell(
                        onTap: () {
                          Get.to(() => const ChatRoomScreen(), arguments: chat.id);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _ChatTile(chat: chat),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemCount: controller.rxChats.length,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            const _EncryptedFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF003BFF), Color(0xFF001A8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x55003BFF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF003BFF), size: 22),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF003BFF),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD6B8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              size: 20,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final ChatController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: Color(0xFF8A8A8A), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search conversations...',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          _TabPill(title: 'My\nEnquiries', selected: true),
          SizedBox(width: 10),
          _TabPill(title: 'My\nProducts'),
          SizedBox(width: 10),
          _TabPill(title: 'Archived'),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String title;
  final bool selected;

  const _TabPill({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF003BFF), Color(0xFF001C99)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selected ? null : Colors.white,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x40003BFF),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF2E2E2E),
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          height: 1.2,
        ),
      ),
    );
  }
}

class _EncryptedFooter extends StatelessWidget {
  const _EncryptedFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.lock_outline_rounded, color: Color(0xFFB5B5B5), size: 26),
        SizedBox(height: 5),
        Text(
          'END-TO-END ENCRYPTED MESSAGING',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF9E9E9E),
            letterSpacing: 2.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatEnquiry chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.myUnread > 0;
    final initials = chat.peerName.isNotEmpty
        ? chat.peerName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : 'S';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: hasUnread ? Border.all(color: const Color(0xFFE8EDFF), width: 1.5) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFD6E0EE),
            backgroundImage: chat.productImage.isNotEmpty
                ? NetworkImage(chat.productImage)
                : null,
            child: chat.productImage.isEmpty
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF0A2540),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.peerName.isNotEmpty ? chat.peerName : chat.productTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chat.lastAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnread ? const Color(0xFF0046FF) : const Color(0xFF8A8A8A),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Message preview
                Text(
                  chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                // Product label tag
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 13,
                      color: Color(0xFF003BFF),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${chat.productTitle}  •  ₹${chat.productPrice}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF003BFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Unread badge
          if (hasUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFD4C000),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${chat.myUnread}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
