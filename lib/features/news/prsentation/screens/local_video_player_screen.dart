import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:share_plus/share_plus.dart';
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
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
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
        aspectRatio: _videoPlayerController.value.aspectRatio > 0
            ? _videoPlayerController.value.aspectRatio
            : 16 / 9,
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
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(widget.news.createdAt);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
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
            'Video Bulletin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: darkText,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: primary, size: 20),
              tooltip: 'Share Video',
              onPressed: () {
                Share.share(
                  '${widget.news.title}\n\nWatch on Rozgar Adda App:\n${widget.news.videoUrl}',
                  subject: widget.news.title,
                );
              },
            ),
            const SizedBox(width: 6),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: borderGrey),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player 16:9 Frame
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
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load video: $_errorMessage',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _chewieController != null &&
                            _chewieController!.videoPlayerController.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : const Center(
                            child: CircularProgressIndicator(color: primary),
                          ),
              ),
            ),

            // Video Details Information
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge & Published Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primary.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded, color: primary, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'VIDEO REPORT',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time_rounded, size: 14, color: greyText),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: greyText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Video Title
                    Text(
                      widget.news.title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: borderGrey),
                    const SizedBox(height: 14),

                    // Video Description
                    if (widget.news.description.isNotEmpty) ...[
                      const Text(
                        'About this Report',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.news.description,
                        style: const TextStyle(
                          color: mediumText,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Verified Badge Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGrey),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Verified Citizen & Employment Video Broadcast',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
