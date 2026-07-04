import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/news_item.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final YoutubeNews news;

  const YoutubePlayerScreen({super.key, required this.news});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    
    // Parse YouTube ID safely, with a fallback parser if needed.
    String videoId = widget.news.youtubeId;
    if (videoId.isEmpty && widget.news.youtubeUrl.isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(widget.news.youtubeUrl) ?? '';
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (mounted && _controller.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video when navigating away
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(widget.news.createdAt);
    
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFD4A017),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFD4A017),
          handleColor: Color(0xFFD4A017),
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white10,
        ),
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1E3C),
            foregroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            ),
            title: const Text(
              'Video Player',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
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
                  child: player,
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
                              color: const Color(0xFFFF0000).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'YOUTUBE',
                              style: TextStyle(
                                color: Color(0xFFFF0000),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF8A8FA3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Color(0xFF8A8FA3),
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
                          color: Color(0xFF1A1E3C),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const Divider(height: 32, thickness: 1.2, color: Color(0xFFE0E0EE)),
                      
                      // Video Description
                      if (widget.news.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            color: Color(0xFF1A1E3C),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.news.description,
                          style: const TextStyle(
                            color: Color(0xFF2C3248),
                            fontSize: 14,
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
      },
    );
  }
}
