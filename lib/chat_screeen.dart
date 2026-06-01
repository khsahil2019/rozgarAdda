import 'package:flutter/material.dart';

/// One-to-one chat screen — matches editorial messaging UI (navy header, accent bubbles, input bar).
/// Filename matches request: `chat_screeen.dart`
class ChatScreeen extends StatefulWidget {
  const ChatScreeen({super.key});

  @override
  State<ChatScreeen> createState() => _ChatScreeenState();
}

class _ChatScreeenState extends State<ChatScreeen> {
  static const Color _navy = Color(0xFF001A99);
  static const Color _yellow = Color(0xFFFFD700);
  static const Color _chatBg = Color(0xFFF5F5F7);

  final TextEditingController _draftController = TextEditingController();

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _chatBg,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _EditorialWatermark()),
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: const [
                    _DatePill(label: 'TODAY, OCT 24'),
                    SizedBox(height: 16),
                    _IncomingBubble(
                      text:
                          "Did you see the final proofs for the 'Informed Curator' series? We need the high-resolution imagery by EOD to meet the print deadline.",
                      time: '10:42 AM',
                      accentColor: Color(0xFF2563EB),
                    ),
                    SizedBox(height: 14),
                    _IncomingBubble(
                      urgentLabel: 'URGENT UPDATE',
                      text:
                          'The chief editor just asked for a 200-word abstract for the digital broadsheet version. Can you handle that while I finalize the grid?',
                      time: '10:48 AM',
                      accentColor: _yellow,
                    ),
                    SizedBox(height: 14),
                    _IncomingImageBubble(time: '10:50 AM'),
                    SizedBox(height: 14),
                    _OutgoingBubble(
                      text:
                          "I've just reviewed them. The tonal depth on the cover spread is exceptional. I'll have the assets uploaded to the server in 15 minutes.",
                      time: '10:45 AM',
                    ),
                    SizedBox(height: 14),
                    _OutgoingBubble(
                      text: 'On it. Consider it done. 🖋️',
                      time: '10:52 AM',
                    ),
                  ],
                ),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
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
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF94A3B8),
                child: Icon(Icons.person, color: Colors.white, size: 28),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rakesh Kumar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ONLINE • EDITORIAL LEAD',
                  style: TextStyle(
                    color: Color(0xFFB8C5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
          ),
        ],
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
                  onTap: () {},
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
                          controller: _draftController,
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
              Material(
                color: _yellow,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    _draftController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialWatermark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.rotate(
          angle: -0.35,
          child: Opacity(
            opacity: 0.06,
            child: Text(
              'Editorial',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w600,
                fontFamily: 'Georgia',
                color: _ChatScreeenState._navy,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;

  const _DatePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF52525B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final String text;
  final String time;
  final Color accentColor;
  final String? urgentLabel;

  const _IncomingBubble({
    required this.text,
    required this.time,
    required this.accentColor,
    this.urgentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (urgentLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 6, left: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE566),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                urgentLabel!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
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
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          height: 1.35,
                        ),
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
              time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingImageBubble extends StatelessWidget {
  final String time;

  const _IncomingImageBubble({required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.55,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                14,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                14,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: const Color(0xFF2563EB)),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: const Color(0xFFF1F5F9),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Canvas / floor placeholder (light wood + white area)
                              CustomPaint(painter: _CanvasPreviewPainter()),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.black.withValues(alpha: 0.15),
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final floor = Paint()..color = const Color(0xFFD4C4A8);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
      floor,
    );

    final canvasRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.42),
        width: size.width * 0.72,
        height: size.height * 0.48,
      ),
      const Radius.circular(4),
    );
    final white = Paint()..color = Colors.white;
    final border = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(canvasRect, white);
    canvas.drawRRect(canvasRect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OutgoingBubble extends StatelessWidget {
  final String text;
  final String time;

  const _OutgoingBubble({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
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
              color: _ChatScreeenState._navy,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomRight: const Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: _ChatScreeenState._navy.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 15, color: Color(0xFF38BDF8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
