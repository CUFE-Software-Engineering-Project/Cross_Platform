import 'package:flutter/material.dart';
import 'media_viewer_screen.dart';
import 'inline_video_player.dart';

/// Renders up to four images/videos in a Twitter-style grid while falling back to a
/// placeholder when URLs are still being resolved.
class MediaGallery extends StatelessWidget {
  final List<String> urls;
  final double borderRadius;
  final double minHeight;
  final double maxHeight;

  const MediaGallery({
    super.key,
    required this.urls,
    this.borderRadius = 12,
    this.minHeight = 150,
    this.maxHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    final media = urls.where((url) => url.isNotEmpty).take(4).toList();
    if (media.isEmpty) return const SizedBox.shrink();

    // Convert media keys to full URLs
    final fullUrls = media.map(_getFullMediaUrl).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
        color: Colors.grey[900],
        child: _buildLayout(context, fullUrls),
      ),
    );
  }

  String _getFullMediaUrl(String mediaKey) {
    // If it's already a full URL, return it
    if (mediaKey.startsWith('http://') || mediaKey.startsWith('https://')) {
      return mediaKey;
    }

    // Otherwise, construct the full URL
    return 'https://litex.siematworld.online/media/$mediaKey';
  }

  Widget _buildLayout(BuildContext context, List<String> images) {
    if (images.length == 1) {
      return _buildNetworkImage(context, images.first, 0, images);
    }
    if (images.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNetworkImage(context, images[0], 0, images)),
          const SizedBox(width: 4),
          Expanded(child: _buildNetworkImage(context, images[1], 1, images)),
        ],
      );
    }
    if (images.length == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNetworkImage(context, images[0], 0, images)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildNetworkImage(context, images[1], 1, images),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildNetworkImage(context, images[2], 2, images),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildNetworkImage(context, images[0], 0, images),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _buildNetworkImage(context, images[3], 3, images),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildNetworkImage(context, images[1], 1, images),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _buildNetworkImage(context, images[2], 2, images),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(
    BuildContext context,
    String url,
    int index,
    List<String> allImages,
  ) {
    if (!_isValidMediaUrl(url)) {
      print('⚠️ Invalid media URL: $url');
      return _buildPendingMediaPlaceholder();
    }

    final isVideo = _isVideoUrl(url);
    print('🎬 Media URL: $url, isVideo: $isVideo');

    // For videos, show inline auto-playing player
    if (isVideo) {
      return InlineVideoPlayer(
        videoUrl: url,
        autoPlay: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MediaViewerScreen(mediaUrls: allImages, initialIndex: index),
            ),
          );
        },
      );
    }

    // For images, show with tap to open viewer
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MediaViewerScreen(mediaUrls: allImages, initialIndex: index),
          ),
        );
      },
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                color: Colors.blue,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPendingMediaPlaceholder();
        },
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final path = uri.path.toLowerCase();
    final videoExtensions = [
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
    ];

    // Check if URL has video extension
    final hasVideoExtension = videoExtensions.any((ext) => path.endsWith(ext));

    // Also check if the URL contains common video indicators
    final hasVideoIndicator =
        path.contains('/video') ||
        url.toLowerCase().contains('video') ||
        path.contains('.mp4') ||
        path.contains('.mov');

    return hasVideoExtension || hasVideoIndicator;
  }

  Widget _buildPendingMediaPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 48),
      ),
    );
  }

  bool _isValidMediaUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    return uri.scheme == 'http' ||
        uri.scheme == 'https' ||
        uri.scheme == 'data';
  }
}
