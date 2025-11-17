import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/chat/providers/audiorecordernotifier.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:lite_x/core/theme/palette.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final Function(String)? onSendMessage;
  final Function(String)? onSendAudio;
  final Function(PickedImage)? onSendImage;
  final Function(String)? onSendGif;

  const MessageInputBar({
    super.key,
    this.onSendMessage,
    this.onSendAudio,
    this.onSendImage,
    this.onSendGif,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar>
    with SingleTickerProviderStateMixin {
  final String _giphyApiKey = dotenv.env["giphyApiKey"]!;
  late AnimationController _colorController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _recordingTimer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  PickedImage? selectedImage;
  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _setupAudioPlayer();
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
      ref.read(audioRecorderProvider.notifier).resetReviewPosition();
    } catch (e) {
      debugPrint("Error stopping playback: $e");
    }
  }

  void _setupAudioPlayer() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        _stopPlayback();
      }
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (!mounted) return;

      final audioState = ref.read(audioRecorderProvider);
      if (audioState.status == RecorderStatus.reviewing &&
          _audioPlayer.playing) {
        ref.read(audioRecorderProvider.notifier).updateReviewPosition(position);
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _textController.dispose();
    _colorController.dispose();
    _focusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage?.call(text);
      _textController.clear();
    }
  }

  Future<void> _selectImage() async {
    selectedImage = await pickImage();
    if (selectedImage != null) {
      widget.onSendImage?.call(selectedImage!);
    }
  }

  Future<void> _startRecording() async {
    try {
      final success = await ref
          .read(audioRecorderProvider.notifier)
          .startRecording();
      if (success) {
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          ref.read(audioRecorderProvider.notifier).updateRecordingDuration();
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      await ref.read(audioRecorderProvider.notifier).stopRecording();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await ref.read(audioRecorderProvider.notifier).cancelRecording();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> _togglePlayback() async {
    final path = ref.read(audioRecorderProvider).recordingPath;
    if (path == null) return;

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ProcessingState.completed ||
            _audioPlayer.processingState == ProcessingState.idle) {
          await _audioPlayer.setFilePath(path);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error toggling playback: $e");
    }
  }

  Future<void> _cancelReview() async {
    await _stopPlayback();
    await ref.read(audioRecorderProvider.notifier).cancelReview();
  }

  Future<void> _sendRecording() async {
    await _stopPlayback();
    final path = ref.read(audioRecorderProvider.notifier).sendRecording();
    if (path != null) {
      widget.onSendAudio?.call(path);
    }
  }

  Future<void> _toggleGifPicker() async {
    final gif = await GiphyGet.getGif(
      context: context,
      apiKey: _giphyApiKey,
      lang: GiphyLanguage.english,
      tabColor: Palette.kBrandBlue,
    );
    if (gif != null) {
      final gifUrl = gif.images?.original?.url;
      if (gifUrl != null && gifUrl.isNotEmpty) {
        widget.onSendGif?.call(gifUrl);
      }
    }
  }

  String _formatRecordingDuration(Duration duration) {
    return '${duration.inSeconds}s';
  }

  String _formatReviewDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioRecorderProvider);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: audioState.status == RecorderStatus.idle
            ? Palette.container_message_color
            : Colors.black,
        borderRadius: BorderRadius.circular(26),
      ),
      child: switch (audioState.status) {
        RecorderStatus.idle => _buildIdleView(theme),
        RecorderStatus.recording => _buildRecordingView(audioState, theme),
        RecorderStatus.reviewing => _buildReviewView(audioState, theme),
      },
    );
  }

  Widget _buildIdleView(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.image_outlined,
            color: Palette.kDimIconwhite,
            size: 26,
          ),
          onPressed: _selectImage,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          icon: const Icon(
            Icons.gif_box_outlined,
            color: Palette.kDimIconwhite,
            size: 26,
          ),
          onPressed: _toggleGifPicker,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Expanded(
          child: TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              filled: false,
              hintText: 'Start a message',
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 133, 139, 145),
                fontSize: 16,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,

              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            ),
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            final hastext = value.text.trim().isNotEmpty;
            return IconButton(
              icon: Icon(
                hastext ? Icons.send : Icons.graphic_eq,
                color: hastext ? Palette.kBrandBlue : Palette.kBrandPurple,
                size: 24,
              ),
              onPressed: hastext ? _handleSendMessage : _startRecording,
              onLongPress: !hastext ? _startRecording : null,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordingView(AudioRecorderState audioState, ThemeData theme) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _cancelRecording,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Palette.kDimIconwhite, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              height: 33,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFD1C4F8), Color(0xFFE0D7FF)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _colorController,
                        builder: (context, child) {
                          return Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFFF04F78),
                                const Color(0xFF8E24AA),
                                _colorController.value,
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                      const Text(
                        'Recording',
                        style: TextStyle(
                          color: Color.fromARGB(255, 141, 108, 182),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatRecordingDuration(audioState.remainingDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 239, 57, 103),
                  width: 2.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  size: 14,
                  Icons.stop_rounded,
                  color: Color(0xFFF04F78),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewView(AudioRecorderState audioState, ThemeData theme) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _cancelReview,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Palette.kDimIconwhite, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              height: 33,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 169, 145, 255),
                    Color.fromARGB(255, 163, 141, 244),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GestureDetector(
                onTap: _togglePlayback,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 25,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _audioPlayer.playing ? 'Playing' : 'Play audio',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatReviewDuration(audioState.remainingDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _sendRecording,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF8A6BFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
