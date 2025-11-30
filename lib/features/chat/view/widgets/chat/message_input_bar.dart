import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final Function(String text) onSendMessage;
  final Function(bool isTyping)? onTypingChanged;
  const MessageInputBar({
    super.key,
    required this.onSendMessage,

    this.onTypingChanged,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  final TextEditingController _textController = TextEditingController();
  Timer? _typingTimer;
  bool _isTyping = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _colorController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;

    if (hasText && !_isTyping) {
      _isTyping = true;
      widget.onTypingChanged?.call(true);
    }
    _typingTimer?.cancel();

    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping && mounted) {
          _isTyping = false;
          widget.onTypingChanged?.call(false);
        }
      });
    } else if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
    _typingTimer?.cancel();

    widget.onSendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
      ),
      child: _buildIdleView(theme),
    );
  }

  Widget _buildIdleView(ThemeData theme) {
    return Row(
      children: [
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
              onPressed: hastext ? _handleSend : null,
              tooltip: hastext ? 'Send message' : null,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            );
          },
        ),
      ],
    );
  }
}
