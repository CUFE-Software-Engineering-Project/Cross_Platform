import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter/gestures.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfileNormalTweetWidget extends ConsumerWidget implements ProfileTweet {
  const ProfileNormalTweetWidget({
    required this.profileModel,
    required this.profilePostModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel profilePostModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 10, top: 2),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final currentUser = ref.watch(currentUserProvider);
                    final currentUserName = currentUser?.username ?? "";
                    if (currentUserName == this.profileModel.username) {
                      context.pushReplacement(
                        "/profilescreen/${this.profileModel.username}",
                      );
                      return;
                    }
                    context.push(
                      "/profilescreen/${this.profileModel.username}",
                    );
                  },
                  child: BuildSmallProfileImage(
                    mediaId: profilePostModel.profileMediaId,
                    radius: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 120),
                            child: Text(
                              this.profilePostModel.userDisplayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "@${this.profilePostModel.userUserName}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "· ${profilePostModel.timeAgo}",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/grok.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _openProfileTweetOptions(
                              context,
                              ref,
                              this.profilePostModel,
                            );
                          },
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    context.push(
                      "/tweetDetailsScreen/${this.profilePostModel.id}",
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: double.infinity),
                      profilePostModel.text.isEmpty
                          ? const SizedBox(height: 15)
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ExpandableLinkedText(
                                text: profilePostModel.text,
                              ),
                            ),
                      if (profilePostModel.mediaIds.isNotEmpty)
                        Container(
                          width: 350,
                          constraints: BoxConstraints(maxHeight: 400),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TweetMediaGrid(
                            mediaIds: profilePostModel.mediaIds,
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                    ],
                  ),
                ),
                InterActionsRowOfTweet(tweet: this.profilePostModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableLinkedText extends StatefulWidget {
  const ExpandableLinkedText({
    super.key,
    required this.text,
    this.trimLines = 3,
  });

  final String text;
  final int trimLines;

  @override
  State<ExpandableLinkedText> createState() => _ExpandableLinkedTextState();
}

class _ExpandableLinkedTextState extends State<ExpandableLinkedText> {
  bool _expanded = false;
  String? _trimmed;
  bool _isTrimmed = false;

  final _showMoreRecognizer = TapGestureRecognizer();
  final _showLessRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _showMoreRecognizer.dispose();
    _showLessRecognizer.dispose();
    super.dispose();
  }

  TextSpan _buildSpans(String displayText) {
    final regex = RegExp(r'(@[A-Za-z0-9_]+|#[A-Za-z0-9_]+)');
    final matches = regex.allMatches(displayText);

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final m in matches) {
      if (m.start > currentIndex) {
        spans.add(
          TextSpan(
            text: displayText.substring(currentIndex, m.start),
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        );
      }

      final token = m.group(0)!;
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: Colors.blue, fontSize: 16),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (token.contains("@")) {
                try {
                  context.push("/profilescreen/${token.substring(1)}");
                } catch (e) {}
              } else if (token.contains("#")) {
                // TODO: goto hashtag screen
              }
            },
        ),
      );

      currentIndex = m.end;
    }

    if (currentIndex < displayText.length) {
      spans.add(
        TextSpan(
          text: displayText.substring(currentIndex),
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  // Binary search to find the largest substring that fits within trimLines
  String _computeTrimmed(
    String fullText,
    TextStyle style,
    double maxWidth,
    int maxLines,
  ) {
    final tp = TextPainter(textDirection: TextDirection.ltr);

    int low = 0;
    int high = fullText.length;
    String fitted = fullText;

    while (low <= high) {
      final mid = ((low + high) / 2).floor();
      final candidate = fullText.substring(0, mid).trim();
      tp.text = TextSpan(text: candidate + '... Show more', style: style);
      tp.maxLines = maxLines;
      tp.layout(maxWidth: maxWidth);
      if (tp.didExceedMaxLines) {
        high = mid - 1;
      } else {
        fitted = candidate;
        low = mid + 1;
      }
    }

    return fitted;
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(fontSize: 16, color: Colors.white);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_expanded && _trimmed == null) {
          final trimmed = _computeTrimmed(
            widget.text,
            baseStyle,
            constraints.maxWidth,
            widget.trimLines,
          );
          _trimmed = trimmed;
          _isTrimmed = trimmed.length < widget.text.length;
        }

        if (!_isTrimmed) {
          return RichText(text: _buildSpans(widget.text));
        }

        if (_expanded) {
          final full = _buildSpans(widget.text);
          final spans = <TextSpan>[
            full,
            TextSpan(text: ' ', style: baseStyle),
            TextSpan(
              text: 'show less',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              recognizer: _showLessRecognizer
                ..onTap = () {
                  setState(() {
                    _expanded = false;
                  });
                },
            ),
          ];
          return RichText(text: TextSpan(children: spans));
        } else {
          final display = _trimmed ?? widget.text;
          final mainSpan = _buildSpans(display);
          final spans = <TextSpan>[
            mainSpan,
            TextSpan(text: '... ', style: baseStyle),
            TextSpan(
              text: 'Show more',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              recognizer: _showMoreRecognizer
                ..onTap = () {
                  setState(() {
                    _expanded = true;
                  });
                },
            ),
          ];
          return RichText(text: TextSpan(children: spans));
        }
      },
    );
  }
}

void _openProfileTweetOptions(
  BuildContext context,
  WidgetRef ref,
  ProfileTweetModel tweet,
) async {
  final currentUser = ref.watch(currentUserProvider);
  final currneusername = currentUser?.username ?? "";

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileTweetOptin(
            text: "Pin to profile",
            icon: Icons.push_pin_outlined,
            onPress: () async {
              await Future.delayed(Duration(milliseconds: 100));
              context.pop();
            },
          ),
          if (currneusername == tweet.userUserName)
            ProfileTweetOptin(
              text: "Delete post",
              icon: Icons.delete,
              onPress: () async {
                final delete = await ref.watch(deleteTweetProvider);
                final res = await delete(tweet.id);
                res.fold(
                  (l) {
                    showSmallPopUpMessage(
                      context: context,
                      message: l.message,
                      borderColor: Colors.red,
                      icon: Icon(Icons.error, color: Colors.red),
                    );
                  },
                  (r) {
                    showSmallPopUpMessage(
                      context: context,
                      message: "Tweet deleted successfully",
                      borderColor: Colors.blue,
                      icon: Icon(Icons.check, color: Colors.blue),
                    );
                    if (currentUser != null)
                      ref.refresh(profilePostsProvider(currentUser.username));
                  },
                );
                context.pop();
              },
            ),
          if (currneusername == tweet.userUserName)
            ProfileTweetOptin(
              text: "Change who can reply",
              icon: Icons.mode_comment_outlined,
              onPress: () async {
                await Future.delayed(Duration(milliseconds: 100));
                context.pop();
              },
            ),
          ProfileTweetOptin(
            text: "Request Community Note",
            icon: Icons.public,
            onPress: () async {
              await Future.delayed(Duration(milliseconds: 100));
              context.pop();
            },
          ),
        ],
      );
    },
  );
}

class ProfileTweetOptin extends StatelessWidget {
  const ProfileTweetOptin({
    super.key,
    required this.text,
    required this.icon,
    required this.onPress,
  });
  final String text;
  final IconData icon;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10),
      child: ListTile(
        title: Text(text, style: TextStyle(fontSize: 18)),
        leading: Icon(icon, color: Colors.grey, size: 25),
        onTap: () {
          onPress();
        },
      ),
    );
  }
}

class TweetMediaGrid extends ConsumerStatefulWidget {
  const TweetMediaGrid({super.key, required this.mediaIds});
  final List<String> mediaIds;

  @override
  ConsumerState<TweetMediaGrid> createState() => _TweetMediaGridState();
}

class _TweetMediaGridState extends ConsumerState<TweetMediaGrid> {
  String? _currentPlayingVideoUrl;

  void _onVideoPlay(String videoUrl) {
    setState(() {
      _currentPlayingVideoUrl = videoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildMediaGrid(widget.mediaIds, ref);
  }

  Widget _buildMediaSkeleton() {
    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
    );
  }

  Widget _errorContainer(double height) {
    return Container(
      height: height,
      color: Colors.grey[800],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text('Couldn\'t load image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _loadingContainer(double height, {double? value}) {
    return Container(
      height: height,
      color: Colors.grey[900],
      child: Center(child: CircularProgressIndicator(value: value)),
    );
  }

  bool _isVideo(String url) {
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

    print(uri.path + "\n//////////*******************");

    return videoExtensions.any((ext) => path.endsWith(ext));
  }

  Widget _buildMediaItem(String mediaId, WidgetRef ref, double height) {
    final mediaUrl = ref.watch(mediaUrlProvider(mediaId));

    return mediaUrl.when(
      data: (url) {
        if (url == null || url.isEmpty) {
          return _errorContainer(height);
        }
        if (_isVideo(url)) {
          return VideoPlayerWidget(
            videoUrl: url,
            height: height,
            isPlaying: _currentPlayingVideoUrl == url,
            onPlay: () => _onVideoPlay(url),
          );
        }
        return CachedNetworkImage(
          imageUrl: url,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _loadingContainer(height),
          errorWidget: (context, url, error) {
            debugPrint('Image load error for $mediaId: $error');
            return _errorContainer(height);
          },
        );
      },
      loading: () => _loadingContainer(height),
      error: (error, stack) {
        debugPrint('Media URL fetch error for $mediaId: $error');
        return _errorContainer(height);
      },
    );
  }

  Widget _buildMediaGrid(List<String> photos, WidgetRef ref) {
    if (photos.isEmpty) return const SizedBox.shrink();

    if (photos.length == 1) {
      return _buildMediaItem(photos[0], ref, 300);
    }

    if (photos.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildMediaItem(photos[0], ref, 150)),
          Expanded(child: _buildMediaItem(photos[1], ref, 150)),
        ],
      );
    } else if (photos.length == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildMediaItem(photos[0], ref, 300)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildMediaItem(photos[1], ref, 148)),
                const SizedBox(height: 4),
                Expanded(child: _buildMediaItem(photos[2], ref, 148)),
              ],
            ),
          ),
        ],
      );
    } else if (photos.length == 4) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildMediaItem(photos[0], ref, 148)),
                const SizedBox(height: 4),
                Expanded(child: _buildMediaItem(photos[3], ref, 148)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildMediaItem(photos[1], ref, 148)),
                const SizedBox(height: 4),
                Expanded(child: _buildMediaItem(photos[2], ref, 148)),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.height,
    this.isPlaying = true,
    this.onPlay,
  });

  final String videoUrl;
  final double height;
  final bool isPlaying;
  final VoidCallback? onPlay;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(0.0); // Start muted
      _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _toggleMute() {
    if (!mounted) return;
    setState(() {
      _isMuted = !_isMuted;
      try {
        _controller.setVolume(_isMuted ? 0.0 : 1.0);
      } catch (e) {
        debugPrint('Error toggling mute: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      if (_controller != null) {
        _controller.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing video controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[800],
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 32),
              SizedBox(height: 8),
              Text(
                'Couldn\'t load video',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey[900],
        height: widget.height,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return VisibilityDetector(
      key: Key('video_${widget.videoUrl}'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!mounted) return;
        try {
          // Only auto-play/pause if this is the current playing video
          if (info.visibleFraction > 0.5) {
            // More than 50% visible - notify parent and play
            widget.onPlay?.call();
            if (!_controller.value.isPlaying) {
              _controller.play();
            }
          } else {
            // Less than 50% visible - pause
            if (_controller.value.isPlaying) {
              _controller.pause();
            }
          }
        } catch (e) {
          debugPrint('Error in visibility detection: $e');
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inline video player
          SizedBox(
            height: widget.height,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          // Mute toggle icon (bottom-left corner)
          Positioned(
            bottom: 8,
            left: 8,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
