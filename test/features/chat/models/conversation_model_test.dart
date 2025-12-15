import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';

void main() {
  const String currentUserId = 'user_1';
  final DateTime fixedDate = DateTime(2023, 1, 1);

  final ConversationModel baseModel = ConversationModel(
    id: 'conv_1',
    isDMChat: true,
    createdAt: fixedDate,
    updatedAt: fixedDate,
    participantIds: ['user_1', 'user_2'],
    lastMessageContent: 'Hello',
    lastMessageTime: fixedDate,
    lastMessageSenderId: 'user_2',
    unseenCount: 2,
    dmPartnerUserId: 'user_2',
    dmPartnerName: 'Partner Name',
    dmPartnerUsername: 'partner_user',
    dmPartnerProfileKey: 'media_key',
    lastMessageType: 'text',
  );

  group('ConversationModel', () {
    test('should match individual properties initialized via constructor', () {
      expect(baseModel.id, 'conv_1');
      expect(baseModel.isDMChat, true);
      expect(baseModel.createdAt, fixedDate);
      expect(baseModel.participantIds, ['user_1', 'user_2']);
      expect(baseModel.unseenCount, 2);
    });

    group('fromApiResponse', () {
      test('should parse valid DM response correctly', () {
        final Map<String, dynamic> json = {
          'id': 'conv_1',
          'DMChat': true,
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
          'unseenMessagesCount': 5,
          'chatUsers': [
            {'userId': 'user_1'},
            {
              'userId': 'user_2',
              'user': {
                'id': 'user_2',
                'name': 'Partner',
                'username': 'partner_u',
                'profileMediaId': 'key_1',
              },
            },
          ],
          'messages': [
            {
              'content': 'Short message',
              'createdAt': fixedDate.toIso8601String(),
              'userId': 'user_2',
            },
          ],
        };

        final model = ConversationModel.fromApiResponse(json, currentUserId);

        expect(model.id, 'conv_1');
        expect(model.isDMChat, true);
        expect(model.participantIds, containsAll(['user_1', 'user_2']));
        expect(model.lastMessageContent, 'Short message');
        expect(model.dmPartnerName, 'Partner');
        expect(model.dmPartnerUserId, 'user_2');
        expect(model.unseenCount, 5);
        expect(model.lastMessageType, 'text');
      });

      test('should truncate long last message content', () {
        final String longMessage = 'a' * 100;
        final Map<String, dynamic> json = {
          'id': 'conv_2',
          'DMChat': true,
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
          'chatUsers': [],
          'messages': [
            {
              'content': longMessage,
              'createdAt': fixedDate.toIso8601String(),
              'userId': 'user_2',
            },
          ],
        };

        final model = ConversationModel.fromApiResponse(json, currentUserId);
        expect(model.lastMessageContent?.length, 80);
        expect(model.lastMessageContent, 'a' * 80);
      });

      test('should handle empty messages list', () {
        final Map<String, dynamic> json = {
          'id': 'conv_3',
          'DMChat': false,
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
          'chatUsers': [],
          'messages': [],
        };

        final model = ConversationModel.fromApiResponse(json, currentUserId);
        expect(model.lastMessageContent, null);
        expect(model.lastMessageTime, null);
      });

      test('should handle null/missing fields gracefully', () {
        final Map<String, dynamic> json = {
          'id': 'conv_4',
          'DMChat': true,
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
        };

        final model = ConversationModel.fromApiResponse(json, currentUserId);
        expect(model.participantIds, isEmpty);
        expect(model.unseenCount, 0);
      });

      test(
        'should not parse partner details if not DM or single participant',
        () {
          final Map<String, dynamic> json = {
            'id': 'conv_5',
            'DMChat': false,
            'createdAt': fixedDate.toIso8601String(),
            'updatedAt': fixedDate.toIso8601String(),
            'chatUsers': [
              {'userId': 'user_1'},
              {
                'userId': 'user_2',
                'user': {'name': 'GroupUser'},
              },
            ],
          };

          final model = ConversationModel.fromApiResponse(json, currentUserId);
          expect(model.dmPartnerName, null);
        },
      );
    });

    group('Getters and Logic methods', () {
      test('isGroup should return negation of isDMChat', () {
        final dmModel = baseModel.copyWith(isDMChat: true);
        final groupModel = baseModel.copyWith(isDMChat: false);

        expect(dmModel.isGroup, false);
        expect(groupModel.isGroup, true);
      });

      test('getOtherParticipantId logic', () {
        expect(baseModel.getOtherParticipantId('user_1'), 'user_2');
        expect(baseModel.getOtherParticipantId('user_2'), 'user_1');

        final selfChat = baseModel.copyWith(participantIds: ['user_1']);
        expect(selfChat.getOtherParticipantId('user_1'), 'user_1');

        final groupChat = baseModel.copyWith(isDMChat: false);
        expect(groupChat.getOtherParticipantId('user_1'), null);
      });
    });

    group('Serialization', () {
      test('toMap and fromMap should work with full data', () {
        final map = baseModel.toMap();
        expect(map['id'], 'conv_1');
        expect(map['isDMChat'], true);
        expect(map['lastMessageTime'], fixedDate.millisecondsSinceEpoch);

        final newModel = ConversationModel.fromMap(map);
        expect(newModel, baseModel);
      });

      test('fromMap should handle null optional fields', () {
        final Map<String, dynamic> map = {
          'id': 'conv_null',
          'isDMChat': false,
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
          'participantIds': ['u1'],
          'unseenCount': 0,
          'lastMessageContent': null,
          'lastMessageTime': null,
          'lastMessageSenderId': null,
          'dmPartnerUserId': null,
          'dmPartnerName': null,
          'dmPartnerUsername': null,
          'dmPartnerProfileKey': null,
          'lastMessageType': null,
        };

        final model = ConversationModel.fromMap(map);
        expect(model.lastMessageContent, null);
        expect(model.lastMessageTime, null);
        expect(model.participantIds, ['u1']);
      });

      test('toJson and fromJson should work', () {
        final jsonStr = baseModel.toJson();
        final newModel = ConversationModel.fromJson(jsonStr);
        expect(newModel, baseModel);
      });
    });

    group('copyWith', () {
      test('should update specified fields and keep others', () {
        final updated = baseModel.copyWith(
          unseenCount: 10,
          groupName: 'IgnoredParam',
          lastMessageContent: 'Updated',
        );

        expect(updated.id, baseModel.id);
        expect(updated.unseenCount, 10);
        expect(updated.lastMessageContent, 'Updated');
        expect(updated.isDMChat, baseModel.isDMChat);
      });

      test('should use current values if parameters are null', () {
        final same = baseModel.copyWith();
        expect(same, baseModel);
      });
    });

    group('Equality and HashCode', () {
      test('should return false for different objects', () {
        final diff = baseModel.copyWith(id: 'diff_id');
        expect(baseModel == diff, false);
      });

      test('identical check', () {
        expect(baseModel == baseModel, true);
      });
    });

    test('toString should return correct string representation', () {
      expect(baseModel.toString(), contains('id: conv_1'));
      expect(baseModel.toString(), contains('isDMChat: true'));
      expect(baseModel.toString(), contains('unseenCount: 2'));
    });
  });
}
