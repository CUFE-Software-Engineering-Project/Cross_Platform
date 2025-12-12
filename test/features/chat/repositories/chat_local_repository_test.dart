import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_local_repository_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late ChatLocalRepository repository;
  late MockBox<ConversationModel> mockConversationsBox;
  late MockBox<MessageModel> mockMessagesBox;

  setUp(() {
    mockConversationsBox = MockBox<ConversationModel>();
    mockMessagesBox = MockBox<MessageModel>();

    repository = ChatLocalRepository.forTesting(
      conversationsBox: mockConversationsBox,
      messagesBox: mockMessagesBox,
    );
  });

  group('Message Operations', () {
    group('getCachedMessages', () {
      test('should return sorted messages for a chat in descending order', () {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'First',
          createdAt: DateTime(2025, 1, 1),
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Second',
          createdAt: DateTime(2025, 1, 2),
          messageType: 'text',
        );

        final msg3 = MessageModel(
          id: 'msg3',
          chatId: 'chat2',
          userId: 'user1',
          content: 'Other chat',
          createdAt: DateTime(2025, 1, 3),
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2, msg3]);

        final result = repository.getCachedMessages('chat1');

        expect(result.length, 2);
        expect(result.first.id, 'msg2'); // Most recent first
        expect(result.last.id, 'msg1');
      });

      test('should return empty list when no messages exist for chat', () {
        when(mockMessagesBox.values).thenReturn([]);

        final result = repository.getCachedMessages('chat1');

        expect(result, isEmpty);
      });

      test('should filter messages by chatId correctly', () {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Chat 1',
          createdAt: DateTime(2025, 1, 1),
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat2',
          userId: 'user1',
          content: 'Chat 2',
          createdAt: DateTime(2025, 1, 2),
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2]);

        final result = repository.getCachedMessages('chat1');

        expect(result.length, 1);
        expect(result.first.chatId, 'chat1');
      });

      test('should handle multiple messages with same timestamp', () {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message 1',
          createdAt: DateTime(2025, 1, 1, 10, 0),
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message 2',
          createdAt: DateTime(2025, 1, 1, 10, 0),
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2]);

        final result = repository.getCachedMessages('chat1');

        expect(result.length, 2);
      });
    });

    group('saveMessage', () {
      test('should save message to box and enforce cache limit', () async {
        final testMessage = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Test message',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        when(
          mockMessagesBox.put(testMessage.id, testMessage),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn([testMessage]);

        await repository.saveMessage(testMessage);

        verify(mockMessagesBox.put(testMessage.id, testMessage)).called(1);
      });

      test('should enforce cache limit when message is not READ', () async {
        final messages = List.generate(
          55,
          (i) => MessageModel(
            id: 'msg$i',
            chatId: 'chat1',
            userId: 'user1',
            content: 'Message $i',
            createdAt: DateTime(2025, 1, 1).add(Duration(minutes: i)),
            status: 'SENT',
            messageType: 'text',
          ),
        );

        final newMessage = MessageModel(
          id: 'msg56',
          chatId: 'chat1',
          userId: 'user1',
          content: 'New message',
          createdAt: DateTime(2025, 1, 1).add(Duration(minutes: 56)),
          status: 'SENT',
          messageType: 'text',
        );

        when(
          mockMessagesBox.put(newMessage.id, newMessage),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn([...messages, newMessage]);
        when(
          mockMessagesBox.deleteAll(any),
        ).thenAnswer((_) async => Future.value());

        await repository.saveMessage(newMessage);

        verify(mockMessagesBox.put(newMessage.id, newMessage)).called(1);
        verify(mockMessagesBox.deleteAll(any)).called(1);
      });

      test('should not enforce cache limit for READ messages', () async {
        final readMessage = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Read message',
          createdAt: DateTime(2025, 1, 1),
          status: 'READ',
          messageType: 'text',
        );

        when(
          mockMessagesBox.put(readMessage.id, readMessage),
        ).thenAnswer((_) async => Future.value());

        await repository.saveMessage(readMessage);

        verify(mockMessagesBox.put(readMessage.id, readMessage)).called(1);
        verifyNever(mockMessagesBox.deleteAll(any));
      });

      test('should save message with different message types', () async {
        final imageMessage = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'image_url',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'image',
        );

        when(
          mockMessagesBox.put(imageMessage.id, imageMessage),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn([imageMessage]);

        await repository.saveMessage(imageMessage);

        verify(mockMessagesBox.put(imageMessage.id, imageMessage)).called(1);
      });
    });

    group('saveInitialMessages', () {
      test('should save multiple messages at once', () async {
        final messages = [
          MessageModel(
            id: 'msg1',
            chatId: 'chat1',
            userId: 'user1',
            content: 'Message 1',
            createdAt: DateTime(2025, 1, 1),
            messageType: 'text',
          ),
          MessageModel(
            id: 'msg2',
            chatId: 'chat1',
            userId: 'user1',
            content: 'Message 2',
            createdAt: DateTime(2025, 1, 2),
            messageType: 'text',
          ),
        ];

        final entries = {for (var msg in messages) msg.id: msg};

        when(
          mockMessagesBox.putAll(entries),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn(messages);

        await repository.saveInitialMessages(messages);

        verify(mockMessagesBox.putAll(entries)).called(1);
      });

      test('should handle empty message list', () async {
        final List<MessageModel> messages = [];
        final entries = <String, MessageModel>{};

        when(
          mockMessagesBox.putAll(entries),
        ).thenAnswer((_) async => Future.value());

        await repository.saveInitialMessages(messages);

        verify(mockMessagesBox.putAll(entries)).called(1);
      });

      test(
        'should enforce cache limit after saving initial messages',
        () async {
          final messages = List.generate(
            60,
            (i) => MessageModel(
              id: 'msg$i',
              chatId: 'chat1',
              userId: 'user1',
              content: 'Message $i',
              createdAt: DateTime(2025, 1, 1).add(Duration(minutes: i)),
              messageType: 'text',
            ),
          );

          final entries = {for (var msg in messages) msg.id: msg};

          when(
            mockMessagesBox.putAll(entries),
          ).thenAnswer((_) async => Future.value());
          when(mockMessagesBox.values).thenReturn(messages);
          when(
            mockMessagesBox.deleteAll(any),
          ).thenAnswer((_) async => Future.value());

          await repository.saveInitialMessages(messages);

          verify(mockMessagesBox.putAll(entries)).called(1);
          verify(mockMessagesBox.deleteAll(any)).called(1);
        },
      );
    });

    group('replaceTempWithServerMessage', () {
      test('should delete temp message and save server message', () async {
        final tempId = 'temp_123';
        final serverMessage = MessageModel(
          id: 'server_456',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Temp message',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        when(mockMessagesBox.containsKey(tempId)).thenReturn(true);
        when(
          mockMessagesBox.delete(tempId),
        ).thenAnswer((_) async => Future.value());
        when(
          mockMessagesBox.put(serverMessage.id, serverMessage),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn([serverMessage]);

        await repository.replaceTempWithServerMessage(
          tempId: tempId,
          serverMessage: serverMessage,
        );

        verify(mockMessagesBox.delete(tempId)).called(1);
        verify(mockMessagesBox.put(serverMessage.id, serverMessage)).called(1);
      });

      test('should handle case when temp message does not exist', () async {
        final tempId = 'temp_123';
        final serverMessage = MessageModel(
          id: 'server_456',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        when(mockMessagesBox.containsKey(tempId)).thenReturn(false);
        when(
          mockMessagesBox.put(serverMessage.id, serverMessage),
        ).thenAnswer((_) async => Future.value());
        when(mockMessagesBox.values).thenReturn([serverMessage]);

        await repository.replaceTempWithServerMessage(
          tempId: tempId,
          serverMessage: serverMessage,
        );

        verifyNever(mockMessagesBox.delete(tempId));
        verify(mockMessagesBox.put(serverMessage.id, serverMessage)).called(1);
      });
    });

    group('markMessagesAsRead', () {
      test('should mark unread messages as READ', () async {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user2',
          content: 'Message 1',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat1',
          userId: 'user2',
          content: 'Message 2',
          createdAt: DateTime(2025, 1, 2),
          status: 'SENT',
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2]);
        await repository.markMessagesAsRead('chat1', 'user2');
        expect(msg1.status, 'READ');
        expect(msg2.status, 'READ');
        verify(mockMessagesBox.put('msg1', msg1)).called(1);
        verify(mockMessagesBox.put('msg2', msg2)).called(1);
      });

      test('should not modify already READ messages', () async {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message 1',
          createdAt: DateTime(2025, 1, 1),
          status: 'READ',
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1]);
        await repository.markMessagesAsRead('chat1', 'user1');
        expect(msg1.status, 'READ');
      });

      test('should only mark messages for specified user and chat', () async {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'User 1 message',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat1',
          userId: 'user2',
          content: 'User 2 message',
          createdAt: DateTime(2025, 1, 2),
          status: 'SENT',
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2]);

        await repository.markMessagesAsRead('chat1', 'user1');

        expect(msg1.status, 'READ');
        expect(msg2.status, 'SENT');
      });
    });

    group('markMessageAsSent', () {
      test('should mark message as SENT when not READ', () async {
        final message = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message',
          createdAt: DateTime(2025, 1, 1),
          status: 'PENDING',
          messageType: 'text',
        );

        when(mockMessagesBox.get('msg1')).thenReturn(message);

        await repository.markMessageAsSent('msg1');

        expect(message.status, 'SENT');
      });

      test('should not modify READ messages', () async {
        final message = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message',
          createdAt: DateTime(2025, 1, 1),
          status: 'READ',
          messageType: 'text',
        );

        when(mockMessagesBox.get('msg1')).thenReturn(message);

        await repository.markMessageAsSent('msg1');

        expect(message.status, 'READ');
      });

      test('should handle non-existent message', () async {
        when(mockMessagesBox.get('nonexistent')).thenReturn(null);

        await repository.markMessageAsSent('nonexistent');

        verify(mockMessagesBox.get('nonexistent')).called(1);
      });
    });

    group('getPendingMessages', () {
      test('should return only SENDING messages for chat', () {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Sending',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENDING',
          messageType: 'text',
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Sent',
          createdAt: DateTime(2025, 1, 2),
          status: 'SENT',
          messageType: 'text',
        );

        final msg3 = MessageModel(
          id: 'msg3',
          chatId: 'chat2',
          userId: 'user1',
          content: 'Other chat sending',
          createdAt: DateTime(2025, 1, 3),
          status: 'SENDING',
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1, msg2, msg3]);

        final result = repository.getPendingMessages('chat1');

        expect(result.length, 1);
        expect(result.first.id, 'msg1');
      });

      test('should return empty list when no pending messages', () {
        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Sent',
          createdAt: DateTime(2025, 1, 1),
          status: 'SENT',
          messageType: 'text',
        );

        when(mockMessagesBox.values).thenReturn([msg1]);

        final result = repository.getPendingMessages('chat1');

        expect(result, isEmpty);
      });
    });

    group('deleteMessage', () {
      test('should delete message by id', () async {
        when(
          mockMessagesBox.delete('msg1'),
        ).thenAnswer((_) async => Future.value());

        await repository.deleteMessage('msg1');

        verify(mockMessagesBox.delete('msg1')).called(1);
      });
    });
  });

  group('Conversation Operations', () {
    group('upsertConversations', () {
      test('should save multiple conversations', () async {
        final conv1 = ConversationModel(
          id: 'conv1',
          isDMChat: true,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          participantIds: ['user1', 'user2'],
        );

        final conv2 = ConversationModel(
          id: 'conv2',
          isDMChat: false,
          createdAt: DateTime(2025, 1, 2),
          updatedAt: DateTime(2025, 1, 2),
          participantIds: ['user1', 'user2', 'user3'],
        );

        when(
          mockConversationsBox.put(conv1.id, conv1),
        ).thenAnswer((_) async => Future.value());
        when(
          mockConversationsBox.put(conv2.id, conv2),
        ).thenAnswer((_) async => Future.value());

        await repository.upsertConversations([conv1, conv2]);

        verify(mockConversationsBox.put(conv1.id, conv1)).called(1);
        verify(mockConversationsBox.put(conv2.id, conv2)).called(1);
      });

      test('should handle empty conversation list', () async {
        await repository.upsertConversations([]);

        verifyNever(mockConversationsBox.put(any, any));
      });
    });

    group('getAllConversations', () {
      test('should return all conversations', () {
        final conv1 = ConversationModel(
          id: 'conv1',
          isDMChat: true,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          participantIds: ['user1', 'user2'],
        );

        final conv2 = ConversationModel(
          id: 'conv2',
          isDMChat: false,
          createdAt: DateTime(2025, 1, 2),
          updatedAt: DateTime(2025, 1, 2),
          participantIds: ['user1', 'user2', 'user3'],
        );

        when(mockConversationsBox.values).thenReturn([conv1, conv2]);

        final result = repository.getAllConversations();

        expect(result.length, 2);
        expect(result, contains(conv1));
        expect(result, contains(conv2));
      });

      test('should return empty list when no conversations', () {
        when(mockConversationsBox.values).thenReturn([]);

        final result = repository.getAllConversations();

        expect(result, isEmpty);
      });
    });

    group('getConversationById', () {
      test('should return conversation when exists', () {
        final testConversation = ConversationModel(
          id: 'conv1',
          isDMChat: true,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
          participantIds: ['user1', 'user2'],
        );

        when(mockConversationsBox.get('conv1')).thenReturn(testConversation);

        final result = repository.getConversationById('conv1');

        expect(result, equals(testConversation));
        verify(mockConversationsBox.get('conv1')).called(1);
      });

      test('should return null when conversation does not exist', () {
        when(mockConversationsBox.get('nonexistent')).thenReturn(null);

        final result = repository.getConversationById('nonexistent');

        expect(result, isNull);
      });
    });

    group('deleteConversation', () {
      test('should delete conversation by id', () async {
        when(
          mockConversationsBox.delete('conv1'),
        ).thenAnswer((_) async => Future.value());

        await repository.deleteConversation('conv1');

        verify(mockConversationsBox.delete('conv1')).called(1);
      });
    });
  });

  group('clearAll', () {
    test('should clear all conversations and messages', () async {
      when(
        mockConversationsBox.clear(),
      ).thenAnswer((_) async => Future.value(0));
      when(mockMessagesBox.clear()).thenAnswer((_) async => Future.value(0));

      await repository.clearAll();

      verify(mockConversationsBox.clear()).called(1);
      verify(mockMessagesBox.clear()).called(1);
    });
  });

  group('Cache Limit Enforcement', () {
    test('should keep only 50 most recent messages per chat', () async {
      final messages = List.generate(
        60,
        (i) => MessageModel(
          id: 'msg$i',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message $i',
          createdAt: DateTime(2025, 1, 1).add(Duration(minutes: i)),
          messageType: 'text',
        ),
      );

      final newMsg = MessageModel(
        id: 'msg_new',
        chatId: 'chat1',
        userId: 'user1',
        content: 'New',
        createdAt: DateTime(2025, 1, 1).add(Duration(minutes: 61)),
        status: 'SENT',
        messageType: 'text',
      );

      when(
        mockMessagesBox.put(newMsg.id, newMsg),
      ).thenAnswer((_) async => Future.value());
      when(mockMessagesBox.values).thenAnswer((_) => [...messages, newMsg]); //
      when(
        mockMessagesBox.deleteAll(any),
      ).thenAnswer((_) async => Future.value());

      await repository.saveMessage(newMsg);

      verify(mockMessagesBox.deleteAll(any)).called(1);
    });

    test('should not delete when messages are 50 or less', () async {
      final messages = List.generate(
        49,
        (i) => MessageModel(
          id: 'msg$i',
          chatId: 'chat1',
          userId: 'user1',
          content: 'Message $i',
          createdAt: DateTime(2025, 1, 1).add(Duration(minutes: i)),
          messageType: 'text',
        ),
      );

      final newMsg = MessageModel(
        id: 'msg_new',
        chatId: 'chat1',
        userId: 'user1',
        content: 'New',
        createdAt: DateTime(2025, 1, 1).add(Duration(minutes: 51)),
        status: 'SENT',
        messageType: 'text',
      );

      when(
        mockMessagesBox.put(newMsg.id, newMsg),
      ).thenAnswer((_) async => Future.value());

      when(mockMessagesBox.values).thenAnswer((_) => [...messages, newMsg]);

      await repository.saveMessage(newMsg);

      verifyNever(mockMessagesBox.deleteAll(any));
    });
  });

  group('Edge Cases', () {
    test('should handle messages with null content', () async {
      final message = MessageModel(
        id: 'msg1',
        chatId: 'chat1',
        userId: 'user1',
        content: null,
        createdAt: DateTime(2025, 1, 1),
        status: 'SENT',
        messageType: 'image',
      );

      when(
        mockMessagesBox.put(message.id, message),
      ).thenAnswer((_) async => Future.value());
      when(mockMessagesBox.values).thenReturn([message]);

      await repository.saveMessage(message);

      verify(mockMessagesBox.put(message.id, message)).called(1);
    });

    test('should handle conversation with minimal data', () async {
      final conversation = ConversationModel(
        id: 'conv1',
        isDMChat: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        participantIds: ['user1'],
      );

      when(
        mockConversationsBox.put(conversation.id, conversation),
      ).thenAnswer((_) async => Future.value());

      await repository.upsertConversations([conversation]);

      verify(mockConversationsBox.put(conversation.id, conversation)).called(1);
    });
  });
}
