import 'package:flutter/material.dart';

/// Renders up to four images in a Twitter-style grid while falling back to a
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
        color: Colors.grey[900],
        child: _buildLayout(media),
      ),
    );
  }

  Widget _buildLayout(List<String> images) {
    if (images.length == 1) {
      return _buildNetworkImage(images.first);
    }
    if (images.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNetworkImage(images[0])),
          const SizedBox(width: 4),
          Expanded(child: _buildNetworkImage(images[1])),
        ],
      );
    }
    if (images.length == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNetworkImage(images[0])),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildNetworkImage(images[1])),
                const SizedBox(height: 4),
                Expanded(child: _buildNetworkImage(images[2])),
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
              Expanded(child: _buildNetworkImage(images[0])),
              const SizedBox(height: 4),
              Expanded(child: _buildNetworkImage(images[3])),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildNetworkImage(images[1])),
              const SizedBox(height: 4),
              Expanded(child: _buildNetworkImage(images[2])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    if (!_isValidMediaUrl(url)) {
      return _buildPendingMediaPlaceholder();
    }

    return Image.network(
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
    );
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
