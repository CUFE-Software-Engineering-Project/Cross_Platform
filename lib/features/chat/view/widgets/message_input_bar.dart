import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
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

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  static const kMediumSpacing = 12.0;
  final String _giphyApiKey = dotenv.env["giphyApiKey"]!;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RecorderController _recorderController = RecorderController();
  PickedImage? selectedImage;
  Timer? _recordingTimer;
  bool _isRecordingInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _recorderController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    try {
      final hasPermission = await _recorderController.checkPermission();
      if (mounted && hasPermission) {
        setState(() => _isRecordingInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
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
    if (!_isRecordingInitialized) return;
    try {
      final success = await ref
          .read(audioRecorderProvider.notifier)
          .startRecording();
      if (success) {
        await _recorderController.record();
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
          _,
        ) {
          ref.read(audioRecorderProvider.notifier).updateDuration();
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      await _recorderController.stop();
      final path = await ref
          .read(audioRecorderProvider.notifier)
          .stopRecording();
      if (path != null) {
        widget.onSendAudio?.call(path);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _recorderController.stop();
      await ref.read(audioRecorderProvider.notifier).cancelRecording();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
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
        color: Palette.container_message_color,
        borderRadius: BorderRadius.circular(26),
      ),
      child: audioState.isRecording
          ? _buildRecordingView(audioState, theme)
          : _buildnorm(theme),
    );
  }

  Widget _buildnorm(ThemeData theme) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(
              Icons.image_outlined,
              color: Palette.kDimIconwhite,
              size: 26,
            ),
            onPressed: _selectImage,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        Container(
          child: IconButton(
            icon: const Icon(
              Icons.gif_box_outlined,
              color: Palette.kDimIconwhite,
              size: 26,
            ),

            onPressed: _toggleGifPicker,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        Expanded(
          child: TextField(
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
              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            ),
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            final hastext = value.text.trim().isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  hastext ? Icons.send : Icons.graphic_eq,
                  color: hastext ? Palette.kBrandBlue : Palette.kBrandPurple,
                  size: 24,
                ),
                onPressed: hastext
                    ? _handleSendMessage
                    : (_isRecordingInitialized ? _startRecording : null),
                onLongPress: !hastext && _isRecordingInitialized
                    ? _startRecording
                    : null,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordingView(AudioRecorderState audioState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.kBrandRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildRecordControlButton(
            icon: Icons.delete_outline,
            backgroundColor: Palette.kBrandRed.withOpacity(0.3),
            iconColor: Palette.kBrandRed,
            onTap: _cancelRecording,
          ),
          const SizedBox(width: kMediumSpacing),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Palette.kBrandRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: kMediumSpacing),
          Expanded(
            child: AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width * 0.5, 40),
              recorderController: _recorderController,
              waveStyle: const WaveStyle(
                waveColor: Palette.kBrandBlue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
              enableGesture: true,
            ),
          ),
          const SizedBox(width: kMediumSpacing),
          Text(
            _formatDuration(audioState.recordingDuration),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(width: kMediumSpacing),
          _buildRecordControlButton(
            icon: Icons.send,
            backgroundColor: Palette.kBrandBlue,
            iconColor: const Color(0xFFFFFFFF),
            onTap: _stopRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordControlButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
