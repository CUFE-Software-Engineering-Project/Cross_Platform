import 'package:flutter/material.dart';

class SubscriptionsTab extends StatelessWidget {
  const SubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        "Nothing to see here -- yet.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 35,
        ),
      ),
    );
  }
}
