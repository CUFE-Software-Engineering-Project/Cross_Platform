import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';

class MockSettingsRepo extends Mock implements SettingsRepo {}

/// Utility to wait for an async condition in tests.
Future<void> waitForCondition(bool Function() cond, {Duration timeout = const Duration(seconds: 1)}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException('Condition not met in time');
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
