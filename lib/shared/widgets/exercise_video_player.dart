import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import 'exercise_lottie_widget.dart';

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

  static const List<String> fallbackUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _startVideoLoad();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _startVideoLoad();
    }
  }

  void _startVideoLoad() {
    final targetUrl = (widget.videoUrl.trim().isNotEmpty && widget.videoUrl.trim().startsWith('http'))
        ? widget.videoUrl.trim()
        : fallbackUrls.first;
    _initializeVideo(targetUrl);
  }

  Future<void> _initializeVideo(String url, [int fallbackIndex = 0]) async {
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _initialized = false;
    });

    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await _controller!.initialize().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          throw Exception('Video load timeout');
        },
      );

      _controller!.setLooping(true);
      _controller!.setVolume(1.0);
      await _controller!.play();

      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Video init error for $url: $e');
      if (fallbackIndex < fallbackUrls.length) {
        final nextFallback = fallbackUrls[fallbackIndex];
        _initializeVideo(nextFallback, fallbackIndex + 1);
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _initialized = false;
          });
        }
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _initialized && _controller != null && _controller!.value.isInitialized
            ? Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
              child: VideoPlayer(_controller!),
            ),
            // Video Controls Overlay
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 22,
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
            ? Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCCFBF1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ExerciseLottieWidget(height: 80),
              const SizedBox(height: 4),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  minimumSize: const Size(120, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _initializeVideo(fallbackUrls.first),
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                label: const Text('Play Video Stream', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        )
            : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.brandTeal),
              SizedBox(height: 8),
              Text('Streaming Exercise Video...', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
