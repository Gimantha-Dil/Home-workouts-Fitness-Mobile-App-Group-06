import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _hasError = false;
      _initialized = false;
    });

    try {
      if (_controller != null) {
        await _controller!.dispose();
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _initialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _initialized && _controller != null
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
                    child: VideoPlayer(_controller!),
                  ),
                  // Video Controls Overlay
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            _controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller!.setVolume(_controller!.value.volume > 0 ? 0.0 : 1.0);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
                        const SizedBox(height: 8),
                        const Text('Unable to load video stream', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.brandTeal),
                          ),
                          onPressed: _initializeVideo,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.brandTeal),
                  ),
      ),
    );
  }
}
