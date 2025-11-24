import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen = false,
    required this.children,
    this.mainIcon = Icons.edit,
    this.mainIconColor = Colors.white,
    this.mainBackgroundColor = Colors.blue,
    this.onPrimaryAction,
  });

  final bool initialOpen;
  final List<ActionButton> children;
  final IconData mainIcon;
  final Color mainIconColor;
  final Color mainBackgroundColor;
  final Future<void> Function()? onPrimaryAction;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleMainFabTap() async {
    if (!_open) {
      _openMenu();
      return;
    }

    _closeMenu();
    if (widget.onPrimaryAction != null) {
      await widget.onPrimaryAction!();
    }
  }

  void _openMenu() {
    setState(() {
      _open = true;
      _controller.forward();
    });
  }

  void _closeMenu() {
    if (!_open) return;
    setState(() {
      _open = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_open,
              child: GestureDetector(
                onTap: _closeMenu,
                child: AnimatedOpacity(
                  opacity: _open ? 0.35 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ),

          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    const double spacing = 60.0;
    const double baseDistance = 70.0;

    for (var i = 0; i < count; i++) {
      final distance = baseDistance + (count - i - 1) * spacing;
      children.add(
        _ExpandingActionButton(
          distance: distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                'Post',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          AnimatedScale(
            scale: _open ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: FloatingActionButton(
              onPressed: _handleMainFabTap,
              shape: const CircleBorder(),
              backgroundColor: widget.mainBackgroundColor,
              child: Icon(
                widget.mainIcon,
                color: widget.mainIconColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.distance,
    required this.progress,
    required this.child,
  });

  final double distance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = distance * progress.value;
        return Positioned(
          right: 6.0,
          bottom: 16.0 + offset,
          child: FadeTransition(
            opacity: progress,
            child: ScaleTransition(scale: progress, child: child!),
          ),
        );
      },
      child: child,
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 4,
              left: 20,
              top: 6,
              bottom: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionIconCircle(icon: icon, isPrimary: isPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIconCircle extends StatelessWidget {
  const _ActionIconCircle({required this.icon, required this.isPrimary});

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.blue, size: 26),
      );
    }

    return Material(
      shape: const CircleBorder(),
      color: Colors.white,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
    );
  }
}
