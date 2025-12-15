import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';

void main() {
  group('SettingsModel', () {
    final testDateTime = DateTime(2024, 1, 1);
    final testModel = SettingsModel(
      username: 'testuser',
      protectedAccount: true,
      allowTagging: false,
      directMessagesFromEveryone: true,
      personalizedAds: false,
      dataSharingWithPartners: true,
      spacesEnabled: false,
      mutedWords: ['spam', 'blocked'],
      lastUpdated: testDateTime,
    );

    test('should create instance with all properties', () {
      expect(testModel.username, 'testuser');
      expect(testModel.protectedAccount, true);
      expect(testModel.allowTagging, false);
      expect(testModel.directMessagesFromEveryone, true);
      expect(testModel.personalizedAds, false);
      expect(testModel.dataSharingWithPartners, true);
      expect(testModel.spacesEnabled, false);
      expect(testModel.mutedWords, ['spam', 'blocked']);
      expect(testModel.lastUpdated, testDateTime);
    });

    group('copyWith', () {
      test('should copy with new username', () {
        final copied = testModel.copyWith(username: 'newuser');
        expect(copied.username, 'newuser');
        expect(copied.protectedAccount, testModel.protectedAccount);
      });

      test('should copy with new protectedAccount', () {
        final copied = testModel.copyWith(protectedAccount: false);
        expect(copied.protectedAccount, false);
        expect(copied.username, testModel.username);
      });

      test('should copy with new allowTagging', () {
        final copied = testModel.copyWith(allowTagging: true);
        expect(copied.allowTagging, true);
      });

      test('should copy with new directMessagesFromEveryone', () {
        final copied = testModel.copyWith(directMessagesFromEveryone: false);
        expect(copied.directMessagesFromEveryone, false);
      });

      test('should copy with new personalizedAds', () {
        final copied = testModel.copyWith(personalizedAds: true);
        expect(copied.personalizedAds, true);
      });

      test('should copy with new dataSharingWithPartners', () {
        final copied = testModel.copyWith(dataSharingWithPartners: false);
        expect(copied.dataSharingWithPartners, false);
      });

      test('should copy with new spacesEnabled', () {
        final copied = testModel.copyWith(spacesEnabled: true);
        expect(copied.spacesEnabled, true);
      });

      test('should copy with new mutedWords', () {
        final newWords = ['test', 'word'];
        final copied = testModel.copyWith(mutedWords: newWords);
        expect(copied.mutedWords, newWords);
      });

      test('should copy with new lastUpdated', () {
        final newDate = DateTime(2025, 1, 1);
        final copied = testModel.copyWith(lastUpdated: newDate);
        expect(copied.lastUpdated, newDate);
      });

      test('should keep original values when no parameters provided', () {
        final copied = testModel.copyWith();
        expect(copied.username, testModel.username);
        expect(copied.protectedAccount, testModel.protectedAccount);
        expect(copied.allowTagging, testModel.allowTagging);
        expect(copied.directMessagesFromEveryone, testModel.directMessagesFromEveryone);
        expect(copied.personalizedAds, testModel.personalizedAds);
        expect(copied.dataSharingWithPartners, testModel.dataSharingWithPartners);
        expect(copied.spacesEnabled, testModel.spacesEnabled);
        expect(copied.mutedWords, testModel.mutedWords);
        expect(copied.lastUpdated, testModel.lastUpdated);
      });
    });

    group('initial', () {
      test('should create initial settings with default values', () {
        final initial = SettingsModel.initial('testuser');
        expect(initial.username, 'testuser');
        expect(initial.protectedAccount, false);
        expect(initial.allowTagging, true);
        expect(initial.directMessagesFromEveryone, false);
        expect(initial.personalizedAds, true);
        expect(initial.dataSharingWithPartners, false);
        expect(initial.spacesEnabled, true);
        expect(initial.mutedWords, const <String>[]);
        expect(initial.lastUpdated, null);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON with all fields', () {
        final json = {
          'username': 'jsonuser',
          'protectedAccount': true,
          'allowTagging': false,
          'directMessagesFromEveryone': true,
          'personalizedAds': false,
          'dataSharingWithPartners': true,
          'spacesEnabled': false,
          'mutedWords': ['word1', 'word2'],
          'lastUpdated': '2024-01-01T00:00:00.000',
        };

        final model = SettingsModel.fromJson(json);
        expect(model.username, 'jsonuser');
        expect(model.protectedAccount, true);
        expect(model.allowTagging, false);
        expect(model.directMessagesFromEveryone, true);
        expect(model.personalizedAds, false);
        expect(model.dataSharingWithPartners, true);
        expect(model.spacesEnabled, false);
        expect(model.mutedWords, ['word1', 'word2']);
        expect(model.lastUpdated, DateTime.parse('2024-01-01T00:00:00.000'));
      });

      test('should handle missing username with default empty string', () {
        final json = <String, dynamic>{};
        final model = SettingsModel.fromJson(json);
        expect(model.username, '');
      });

      test('should handle missing boolean fields with defaults', () {
        final json = <String, dynamic>{};
        final model = SettingsModel.fromJson(json);
        expect(model.protectedAccount, false);
        expect(model.allowTagging, true);
        expect(model.directMessagesFromEveryone, false);
        expect(model.personalizedAds, true);
        expect(model.dataSharingWithPartners, false);
        expect(model.spacesEnabled, true);
      });

      test('should handle missing mutedWords with empty list', () {
        final json = <String, dynamic>{};
        final model = SettingsModel.fromJson(json);
        expect(model.mutedWords, const <String>[]);
      });

      test('should handle null mutedWords', () {
        final json = {'mutedWords': null};
        final model = SettingsModel.fromJson(json);
        expect(model.mutedWords, const <String>[]);
      });

      test('should handle missing lastUpdated', () {
        final json = <String, dynamic>{};
        final model = SettingsModel.fromJson(json);
        expect(model.lastUpdated, null);
      });

      test('should handle null lastUpdated', () {
        final json = {'lastUpdated': null};
        final model = SettingsModel.fromJson(json);
        expect(model.lastUpdated, null);
      });

      test('should handle invalid lastUpdated gracefully', () {
        final json = {'lastUpdated': 'invalid-date'};
        final model = SettingsModel.fromJson(json);
        expect(model.lastUpdated, null);
      });

      test('should convert mutedWords elements to strings', () {
        final json = {
          'mutedWords': [123, 'text', true],
        };
        final model = SettingsModel.fromJson(json);
        expect(model.mutedWords, ['123', 'text', 'true']);
      });
    });

    group('toJson', () {
      test('should serialize to JSON with all fields', () {
        final json = testModel.toJson();
        expect(json['username'], 'testuser');
        expect(json['protectedAccount'], true);
        expect(json['allowTagging'], false);
        expect(json['directMessagesFromEveryone'], true);
        expect(json['personalizedAds'], false);
        expect(json['dataSharingWithPartners'], true);
        expect(json['spacesEnabled'], false);
        expect(json['mutedWords'], ['spam', 'blocked']);
        expect(json['lastUpdated'], testDateTime.toIso8601String());
      });

      test('should serialize null lastUpdated as null', () {
        final model = SettingsModel.initial('user'); // initial has null lastUpdated
        final json = model.toJson();
        expect(json['lastUpdated'], null);
      });

      test('should round trip from JSON and back', () {
        final json1 = testModel.toJson();
        final model2 = SettingsModel.fromJson(json1);
        final json2 = model2.toJson();
        
        expect(json2['username'], json1['username']);
        expect(json2['protectedAccount'], json1['protectedAccount']);
        expect(json2['allowTagging'], json1['allowTagging']);
        expect(json2['directMessagesFromEveryone'], json1['directMessagesFromEveryone']);
        expect(json2['personalizedAds'], json1['personalizedAds']);
        expect(json2['dataSharingWithPartners'], json1['dataSharingWithPartners']);
        expect(json2['spacesEnabled'], json1['spacesEnabled']);
        expect(json2['mutedWords'], json1['mutedWords']);
        expect(json2['lastUpdated'], json1['lastUpdated']);
      });
    });
  });
}
