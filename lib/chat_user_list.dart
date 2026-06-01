import 'package:flutter/material.dart';
import 'package:rojgar/chat_screeen.dart';

// ─── Entry point (remove if integrating into existing app) ───────────────────
void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const ChatUserListScreen(),
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────
class ChatUserListScreen extends StatelessWidget {
  const ChatUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 14),
            const _SearchBox(),
            const SizedBox(height: 16),
            const _CategoryTabs(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreeen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _ChatTile(data: _items[index]),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: _items.length,
              ),
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

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.menu_rounded, color: Color(0xFF003BFF), size: 28),
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
          // Avatar icon (top right – peach circle with file icon)
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

// ─── Search Box ───────────────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  const _SearchBox();

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
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF8A8A8A), size: 20),
          SizedBox(width: 8),
          Text(
            'search conversations...',
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─── Category Tabs ───────────────────────────────────────────────────────────
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

// ─── Encrypted Footer ─────────────────────────────────────────────────────────
class _EncryptedFooter extends StatelessWidget {
  const _EncryptedFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
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

// ─── Chat Tile ────────────────────────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final _ChatItem data;
  const _ChatTile({required this.data});

  @override
  Widget build(BuildContext context) {
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
        border: data.highlighted
            ? Border.all(color: const Color(0xFFE8EDFF), width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with optional online dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              data.imagePath != null
                  ? CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(data.imagePath!),
                      backgroundColor: data.avatarColor,
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundColor: data.avatarColor,
                      child: Text(
                        data.avatarText,
                        style: TextStyle(
                          color: data.avatarTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              if (data.showOnlineDot)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003BFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
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
                        data.name,
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
                      data.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: data.timeColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Message preview
                Text(
                  data.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.3,
                  ),
                ),
                // Footer label (HR tag / PDF tag)
                if (data.footerLabel != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (data.footerIcon != null) ...[
                        Icon(
                          data.footerIcon,
                          size: 13,
                          color: data.footerColor ?? const Color(0xFF003BFF),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          data.footerLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: data.footerColor ?? const Color(0xFF003BFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Unread badge
          if (data.unreadCount != null) ...[
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
                '${data.unreadCount}',
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

// ─── Data Model ───────────────────────────────────────────────────────────────
class _ChatItem {
  final String name;
  final String time;
  final String message;
  final String avatarText;
  final Color avatarColor;
  final Color avatarTextColor;
  final bool showOnlineDot;
  final int? unreadCount;
  final String? footerLabel;
  final Color? footerColor;
  final Color timeColor;
  final bool highlighted;
  final String? imagePath;
  final IconData? footerIcon;

  const _ChatItem({
    required this.name,
    required this.time,
    required this.message,
    required this.avatarText,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.showOnlineDot,
    this.unreadCount,
    this.footerLabel,
    this.footerColor,
    this.timeColor = const Color(0xFF8A8A8A),
    this.highlighted = false,
    this.imagePath,
    this.footerIcon,
  });
}

// ─── Sample Data ──────────────────────────────────────────────────────────────
const List<_ChatItem> _items = [
  _ChatItem(
    name: 'Rakesh Kumar',
    time: '08:36 PM',
    message: 'Are you still looking for the editor?',
    avatarText: 'RK',
    avatarColor: Color(0xFFD6E0EE),
    avatarTextColor: Color(0xFF0A2540),
    showOnlineDot: true,
    unreadCount: 3,
    footerLabel: 'HR RECRUITER  •  Applied 2d ago',
    footerColor: Color(0xFF0046FF),
    timeColor: Color(0xFF0046FF),
    highlighted: true,
    footerIcon: Icons.work_outline_rounded,
  ),
  _ChatItem(
    name: 'Amit Singh',
    time: '10:45 AM',
    message: 'Shared a document: Portfolio_Draft.pdf',
    avatarText: 'AS',
    avatarColor: Color(0xFFD7E9F9),
    avatarTextColor: Color(0xFF163B5C),
    showOnlineDot: false,
    footerLabel: 'PDF ATTACHED',
    footerColor: Color(0xFF0055FF),
    footerIcon: Icons.picture_as_pdf_outlined,
    timeColor: Color(0xFF8A8A8A),
  ),
  _ChatItem(
    name: 'Sarah Chen',
    time: 'YESTERDAY',
    message: 'The interview is scheduled for next week.',
    avatarText: 'SC',
    avatarColor: Color(0xFFE9EAFF),
    avatarTextColor: Color(0xFF2C3388),
    showOnlineDot: false,
    timeColor: Color(0xFF8A8A8A),
  ),
  _ChatItem(
    name: 'Vikram Malhotra',
    time: '6 DAYS AGO',
    message: 'Can you send over the updated version?',
    avatarText: 'VM',
    avatarColor: Color(0xFFD8E8FA),
    avatarTextColor: Color(0xFF163B5C),
    showOnlineDot: true,
    timeColor: Color(0xFF0046FF),
  ),
  _ChatItem(
    name: 'Priya Sharma',
    time: '12 OCT',
    message: 'Thanks for the referral! Much appreciated.',
    avatarText: 'PS',
    avatarColor: Color(0xFFF2E2D8),
    avatarTextColor: Color(0xFF7C4A2A),
    showOnlineDot: false,
    timeColor: Color(0xFF8A8A8A),
  ),
];
