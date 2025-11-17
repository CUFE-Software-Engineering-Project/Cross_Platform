import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

class EmptyInbox extends StatelessWidget {
  const EmptyInbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your\ninbox!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(146, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Drop a line, share posts and more with private conversations between you and others on X.',

              style: TextStyle(
                fontSize: 15,
                color: Palette.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                foregroundColor: Palette.background,
                minimumSize: const Size(210, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Write a message',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
