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
  static const _kEmojiPickerHeight = 250.0;
  static const _kRecordIndicatorSize = 12.0;
  static const _kSmallSpacing = 8.0;
  static const _kMediumSpacing = 12.0;

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

  Future<void> _handlePickImage() async {
    final image = await pickImage();
    if (image != null) {
      widget.onSendImage?.call(image);
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
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
        IconButton(
          icon: Icon(
            _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
            color: Colors.grey[600],
          ),
          onPressed: _toggleEmojiPicker,
        ),
        IconButton(
          icon: Icon(Icons.image_outlined, color: Colors.grey[600]),
          onPressed: _handlePickImage,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Start a message',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ),
        const SizedBox(width: _kSmallSpacing),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            final hasText = value.text.trim().isNotEmpty;
            return GestureDetector(
              onLongPress: !hasText && _isRecordingInitialized
                  ? _startRecording
                  : null,
              onTap: hasText ? _handleSendMessage : null,
              child: CircleAvatar(
                backgroundColor: hasText
                    ? theme.primaryColor
                    : Colors.grey[600],
                child: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordingView(AudioRecorderState audioState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildRecordControlButton(
            icon: Icons.delete_outline,
            backgroundColor: Colors.red.withOpacity(0.2),
            iconColor: Colors.red,
            onTap: _cancelRecording,
          ),
          const SizedBox(width: _kMediumSpacing),
          Container(
            width: _kRecordIndicatorSize,
            height: _kRecordIndicatorSize,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          Expanded(
            child: AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width * 0.5, 50),
              recorderController: _recorderController,
              waveStyle: WaveStyle(
                waveColor: theme.primaryColor,
                extendWaveform: true,
                showMiddleLine: false,
              ),
              enableGesture: true,
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          Text(
            _formatDuration(audioState.recordingDuration),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: _kMediumSpacing),
          _buildRecordControlButton(
            icon: Icons.send,
            backgroundColor: theme.primaryColor,
            iconColor: Colors.white,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
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
            emojiSizeMax: 32,
            columns: 7,
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          categoryViewConfig: CategoryViewConfig(
            iconColor: Colors.grey,
            iconColorSelected: theme.primaryColor,
            indicatorColor: theme.primaryColor,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
