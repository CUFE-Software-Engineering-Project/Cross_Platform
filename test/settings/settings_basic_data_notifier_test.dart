import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/view_model/settings_basic_data_notifier.dart';

import 'settings_mocks.mocks.dart';
import 'mocks.dart' as utils;

void main() {
  group('SettingsBasicDataNotifier', () {
    late MockSettingsRepo mockRepo;

    setUp(() {
      mockRepo = MockSettingsRepo();
    });

    test('loads settings successfully on creation', () async {
      when(mockRepo.getSettings('alice')).thenAnswer((_) async => Right(SettingsModel.initial('alice')));

      final notifier = SettingsBasicDataNotifier(settingsRepo: mockRepo, username: 'alice');

      // wait until load completes
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.settingsData?.username, 'alice');
      expect(notifier.state.errorMessage, isNull);
    });

    test('reports error when loading settings fails', () async {
      when(mockRepo.getSettings('bob')).thenAnswer((_) async => Left(Failure('network')));

      final notifier = SettingsBasicDataNotifier(settingsRepo: mockRepo, username: 'bob');

      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.settingsData, isNull);
      expect(notifier.state.errorMessage, 'network');
    });

    test('updateSettings updates state on success', () async {
      final initial = SettingsModel.initial('carol');
      final updated = initial.copyWith(personalizedAds: false);

      when(mockRepo.getSettings('carol')).thenAnswer((_) async => Right(initial));
      when(mockRepo.updateSettings(newModel: updated)).thenAnswer((_) async => Right(updated));

      final notifier = SettingsBasicDataNotifier(settingsRepo: mockRepo, username: 'carol');
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      // perform update
      await notifier.updateSettings(updated);
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.settingsData?.personalizedAds, false);
      expect(notifier.state.errorMessage, isNull);
    });

    test('updateSettings reports error on failure', () async {
      final initial = SettingsModel.initial('dave');
      final updated = initial.copyWith(personalizedAds: false);

      when(mockRepo.getSettings('dave')).thenAnswer((_) async => Right(initial));
      when(mockRepo.updateSettings(newModel: updated)).thenAnswer((_) async => Left(Failure('fail')));

      final notifier = SettingsBasicDataNotifier(settingsRepo: mockRepo, username: 'dave');
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      await notifier.updateSettings(updated);
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.settingsData?.personalizedAds, initial.personalizedAds);
      expect(notifier.state.errorMessage, 'fail');
    });
  });
}
