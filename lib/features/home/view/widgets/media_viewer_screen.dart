import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoErrors = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize current video if it's a video
    if (_isVideo(widget.mediaUrls[_currentIndex])) {
      _initializeVideo(_currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isVideo(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    return [
      '.mp4',
      '.mov',
      '.avi',
      '.webm',
      '.mkv',
      '.flv',
      '.wmv',
      '.mpeg',
      '.mpg',
      '.3gp',
      '.m4v',
    ].any((ext) => path.endsWith(ext));
  }

  Future<void> _initializeVideo(int index) async {
    if (_videoControllers.containsKey(index)) return;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrls[index]),
        httpHeaders: {
          'Accept': '*/*',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Range': 'bytes=0-',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      controller.setLooping(true);
      controller.setVolume(0.0); // Start muted

      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
          _videoInitialized[index] = true;
          _videoErrors[index] = false;
        });

        // Auto-play if it's the current page
        if (index == _currentIndex) {
          controller.play();
        }
      }
    } catch (e) {
      print('❌ Video initialization error: $e');
      if (mounted) {
        setState(() {
          _videoErrors[index] = true;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    // Pause previous video
    if (_isVideo(widget.mediaUrls[_currentIndex]) &&
        _videoControllers.containsKey(_currentIndex)) {
      _videoControllers[_currentIndex]?.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    // Initialize and play new video
    if (_isVideo(widget.mediaUrls[index])) {
      if (!_videoControllers.containsKey(index)) {
        _initializeVideo(index);
      } else {
        _videoControllers[index]?.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final isVideo = _isVideo(widget.mediaUrls[index]);

          if (isVideo) {
            return _buildVideoPlayer(index);
          } else {
            return _buildImageViewer(index);
          }
        },
      ),
    );
  }

  Widget _buildImageViewer(int index) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          widget.mediaUrls[index],
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF1DA1F2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(int index) {
    final hasError = _videoErrors[index] == true;
    final isInitialized = _videoInitialized[index] == true;

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _videoErrors[index] = false;
                  _videoInitialized[index] = false;
                });
                _initializeVideo(index);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DA1F2)),
      );
    }

    final controller = _videoControllers[index]!;

    return VideoPlayerWithControls(controller: controller);
  }
}

class VideoPlayerWithControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerWithControls({super.key, required this.controller});

  @override
  State<VideoPlayerWithControls> createState() =>
      _VideoPlayerWithControlsState();
}

class _VideoPlayerWithControlsState extends State<VideoPlayerWithControls> {
  bool _showControls = true;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),

          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Play/Pause control
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 48,
                    ),
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // Progress bar and time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFF1DA1F2),
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(widget.controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(widget.controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Mute/Unmute button (top right)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: _toggleMute,
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                size: 28,
              ),
              color: Colors.white,
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
