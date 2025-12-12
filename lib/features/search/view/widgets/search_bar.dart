import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';


class AppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final String initialText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  const AppSearchBar({
    super.key,
    required this.initialText,
    required this.onSubmitted,
    this.onChanged,
    this.bottom,
    this.onTap,
    this.trailingIcon = Icons.settings_outlined,
  });

  @override
  Size get preferredSize {
    final base = const Size.fromHeight(kToolbarHeight);
    if (bottom == null) return base;
    return Size(base.width, base.height + bottom!.preferredSize.height);
  }

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _submitCooldown;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _submitCooldown?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return AppBar(
      titleSpacing: 0,
      bottom: widget.bottom,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      title: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  onTap: widget.onTap,
                  onChanged: _onChanged,
                  onSubmitted: (s) {
                    if (_submitCooldown?.isActive ?? false) return;
                    widget.onSubmitted(s);
                    _submitCooldown =
                        Timer(const Duration(milliseconds: 800), () {});
                  },
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: Palette.textPrimary, // your primary text color
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Palette.inputBackground, // background color
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Palette.textSecondary,
                    ),
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isFocused ? Colors.blue : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(widget.trailingIcon),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
