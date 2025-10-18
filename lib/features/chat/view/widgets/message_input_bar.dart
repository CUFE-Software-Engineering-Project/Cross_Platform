// ignore_for_file: unused_element, unused_field

import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/chat/providers/audiorecordernotifier.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final Function(String)? onSendMessage;
  final Function(String)? onSendAudio;
  final Function(PickedImage)? onSendImage;

  const MessageInputBar({
    super.key,
    this.onSendMessage,
    this.onSendAudio,
    this.onSendImage,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  static const _kEmojiPickerHeight = 240.0;
  static const _kSmallSpacing = 8.0;
  static const _kMediumSpacing = 12.0;
  static const Color _kBrandBlue = Color(0xFF1D9BF0);
  static const Color _kBrandPurple = Color(0xFF8B5CF6);
  static const Color _kDimIconGray = Color(0xFF71767B);
  static const Color _kBackgroundGray = Color(0xFF2F3336);
  static const Color _kBrandRed = Color(0xFFF4212E);

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RecorderController _recorderController = RecorderController();

  bool _showEmojiPicker = false;
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

  Future<void> _handlePickImage() async {}

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

  void _toggleEmojiPicker() {
    setState(() => _showEmojiPicker = !_showEmojiPicker);
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showEmojiPicker) _buildEmojiPicker(theme),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: _kBackgroundGray,
            borderRadius: BorderRadius.circular(28),
          ),
          child: audioState.isRecording
              ? _buildRecordingView(audioState, theme)
              : _buildNormalView(theme),
        ),
      ],
    );
  }

  Widget _buildNormalView(ThemeData theme) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(
              Icons.image_outlined,
              color: _kDimIconGray,
              size: 24,
            ),
            onPressed: _handlePickImage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),

        Container(
          child: IconButton(
            icon: const Icon(
              Icons.gif_box_outlined,
              color: _kDimIconGray,
              size: 28,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
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
              hintStyle: TextStyle(color: _kDimIconGray, fontSize: 16),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
            maxLines: 5,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            final hasText = value.text.trim().isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  hasText ? Icons.send : Icons.graphic_eq,
                  color: hasText ? _kBrandBlue : _kBrandPurple,
                  size: 24,
                ),
                onPressed: hasText
                    ? _handleSendMessage
                    : (_isRecordingInitialized ? _startRecording : null),
                onLongPress: !hasText && _isRecordingInitialized
                    ? _startRecording
                    : null,
                padding: EdgeInsets.zero,
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
        color: _kBrandRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildRecordControlButton(
            icon: Icons.delete_outline,
            backgroundColor: _kBrandRed.withOpacity(0.3),
            iconColor: _kBrandRed,
            onTap: _cancelRecording,
          ),
          const SizedBox(width: _kMediumSpacing),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _kBrandRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          Expanded(
            child: AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width * 0.5, 40),
              recorderController: _recorderController,
              waveStyle: const WaveStyle(
                waveColor: _kBrandBlue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
              enableGesture: true,
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          Text(
            _formatDuration(audioState.recordingDuration),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          _buildRecordControlButton(
            icon: Icons.send,
            backgroundColor: _kBrandBlue,
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

  Widget _buildEmojiPicker(ThemeData theme) {
    return SizedBox(
      height: _kEmojiPickerHeight,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) =>
            _textController.text += emoji.emoji,
        config: Config(
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28,
            columns: 8,
            backgroundColor: const Color(0xFF1D1D1D),
          ),
          categoryViewConfig: CategoryViewConfig(
            iconColor: _kDimIconGray,
            iconColorSelected: _kBrandBlue,
            indicatorColor: _kBrandBlue,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: const Color(0xFF1D1D1D),
          ),
        ),
      ),
    );
  }
}
