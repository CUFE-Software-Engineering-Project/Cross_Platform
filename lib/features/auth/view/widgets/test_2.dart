import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Test2 extends StatelessWidget {
  const Test2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hi I am test 2"),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: Text(" Return to X - Lite"),
            ),
          ],
        ),
      ),
    );
  }
}
