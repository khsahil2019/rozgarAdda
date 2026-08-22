import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import '../../domain/entities/news_item.dart';

class LocalVideoPlayerScreen extends StatefulWidget {
  final VideoNews news;

  const LocalVideoPlayerScreen({super.key, required this.news});

  @override
  State<LocalVideoPlayerScreen> createState() => _LocalVideoPlayerScreenState();
}

class _LocalVideoPlayerScreenState extends State<LocalVideoPlayerScreen> {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(widget.news.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(uri);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: primary,
          handleColor: primary,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white10,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: primary),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(widget.news.createdAt);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: AppBackButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
        title: const Text(
          'Video News',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: darkText,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderGrey),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Container
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 42,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load video: $_errorMessage',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _chewieController != null &&
                        _chewieController!
                            .videoPlayerController
                            .value
                            .isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: primary,
                      ),
                    ),
            ),
          ),

          // Video Info Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VIDEO',
                          style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Video Title
                  Text(
                    widget.news.title,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    color: borderGrey,
                  ),
                  const SizedBox(height: 16),

                  // Video Description (subject)
                  if (widget.news.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.news.description,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14.5,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
