import 'package:flutter/material.dart';

class TopIcon extends StatelessWidget {
  const TopIcon({super.key, required this.icon, required this.actionFunction});
  final IconData icon;
  final Function actionFunction;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        actionFunction();
      },
      child: CircleAvatar(
        child: Icon(icon, color: Colors.white, size: 25),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        radius: 20,
      ),
    );
  }
}
