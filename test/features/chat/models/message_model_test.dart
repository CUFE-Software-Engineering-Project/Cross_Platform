import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

void main() {
  final baseDate = DateTime(2025, 1, 1);

  group("MessageModel - Constructors & Mapping", () {
    test("fromApiResponse should parse correctly", () {
      final json = {
        "createdMessage": {
          "id": "1",
          "chatId": "chat1",
          "userId": "user1",
          "content": "Hello",
          "createdAt": "2025-01-01T00:00:00.000Z",
          "status": "SENT",
          "user": {
            "username": "aser",
            "name": "Aser",
            "profileMediaId": "img123",
          },
        },
      };

      final msg = MessageModel.fromApiResponse(json);

      expect(msg.id, "1");
      expect(msg.chatId, "chat1");
      expect(msg.userId, "user1");
      expect(msg.content, "Hello");
      expect(msg.status, "SENT");
      expect(msg.senderUsername, "aser");
      expect(msg.senderName, "Aser");
      expect(msg.senderProfileMediaKey, "img123");
      expect(msg.messageType, "text");
    });

    test("fromLoadMessages should parse correctly", () {
      final json = {
        "id": "2",
        "chatId": "chat2",
        "userId": "user2",
        "content": "Hi!",
        "createdAt": "2025-01-01T00:00:00.000Z",
        "status": "READ",
        "user": {
          "username": "mark",
          "name": "Mark",
          "profileMediaId": "media45",
        },
      };

      final msg = MessageModel.fromLoadMessages(json);

      expect(msg.id, "2");
      expect(msg.status, "READ");
      expect(msg.senderUsername, "mark");
    });

    test("toApiRequest should format correctly", () {
      final msg = MessageModel(
        id: "1",
        chatId: "chat1",
        userId: "user1",
        content: "Hello",
        createdAt: baseDate,
        messageType: "text",
      );

      final map = msg.toApiRequest(recipientIds: ["u1", "u2"]);

      expect(map["chatId"], "chat1");
      expect(map["data"]["content"], "Hello");
      expect(map["recipientId"], ["u1", "u2"]);
      expect(map["createdAt"], contains("2025-01-01T00:00:00.000"));
    });
  });

  group("copyWith", () {
    test("copyWith should override fields", () {
      final msg = MessageModel(
        id: "1",
        chatId: "c1",
        userId: "u1",
        content: "old",
        createdAt: baseDate,
        messageType: "text",
      );

      final updated = msg.copyWith(content: "new", status: "READ");

      expect(updated.content, "new");
      expect(updated.status, "READ");
      expect(updated.id, msg.id);
      expect(updated.createdAt, msg.createdAt);
    });
  });

  group("toMap / fromMap", () {
    test("toMap and fromMap should create identical model", () {
      final msg = MessageModel(
        id: "1",
        chatId: "c1",
        userId: "u1",
        content: "Hello",
        createdAt: baseDate,
        status: "SENT",
        senderUsername: "aser",
        senderName: "Aser",
        senderProfileMediaKey: "img",
        messageType: "text",
      );

      final map = msg.toMap();
      final restored = MessageModel.fromMap(map);

      expect(restored, msg);
    });
  });

  group("toJson / fromJson", () {
    test("JSON serialization should work", () {
      final msg = MessageModel(
        id: "22",
        chatId: "chatX",
        userId: "userX",
        content: "Testing json",
        createdAt: baseDate,
        messageType: "text",
      );

      final jsonStr = msg.toJson();
      final restored = MessageModel.fromJson(jsonStr);

      expect(restored.id, msg.id);
      expect(restored.content, msg.content);
      expect(restored.createdAt, msg.createdAt);
    });
  });

  group("Status getters", () {
    test("isPending returns true only for PENDING", () {
      final msg = MessageModel(
        id: "1",
        chatId: "c",
        userId: "u",
        createdAt: baseDate,
        status: "PENDING",
        messageType: "text",
      );
      expect(msg.isPending, true);
    });

    test("isSent returns true for SENT/DELIVERED/READ", () {
      expect(
        MessageModel(
          id: "1",
          chatId: "c",
          userId: "u",
          createdAt: baseDate,
          status: "SENT",
          messageType: "text",
        ).isSent,
        true,
      );

      expect(
        MessageModel(
          id: "1",
          chatId: "c",
          userId: "u",
          createdAt: baseDate,
          status: "DELIVERED",
          messageType: "text",
        ).isSent,
        true,
      );

      expect(
        MessageModel(
          id: "1",
          chatId: "c",
          userId: "u",
          createdAt: baseDate,
          status: "READ",
          messageType: "text",
        ).isSent,
        true,
      );
    });

    test("isRead returns true only for READ", () {
      final msg = MessageModel(
        id: "1",
        chatId: "c",
        userId: "u",
        createdAt: baseDate,
        status: "READ",
        messageType: "text",
      );
      expect(msg.isRead, true);
    });
  });

  group("Equality & hashCode", () {
    test("two identical messages should be equal", () {
      final m1 = MessageModel(
        id: "1",
        chatId: "c1",
        userId: "u1",
        createdAt: baseDate,
        messageType: "text",
      );

      final m2 = MessageModel(
        id: "1",
        chatId: "c1",
        userId: "u1",
        createdAt: baseDate,
        messageType: "text",
      );

      expect(m1, m2);
      expect(m1.hashCode, m2.hashCode);
    });

    test("different messages should not be equal", () {
      final m1 = MessageModel(
        id: "1",
        chatId: "c1",
        userId: "u1",
        createdAt: baseDate,
        messageType: "text",
      );

      final m2 = MessageModel(
        id: "2",
        chatId: "c1",
        userId: "u1",
        createdAt: baseDate,
        messageType: "text",
      );

      expect(m1 == m2, false);
    });
  });

  group("toString", () {
    test("should print truncated content correctly", () {
      final msg = MessageModel(
        id: "1",
        chatId: "chat",
        userId: "user",
        content: "1234567890123456789012345",
        createdAt: baseDate,
        messageType: "text",
      );

      final output = msg.toString();
      expect(output, contains("12345678901234567890"));
    });

    test("should print full content when <= 20 chars", () {
      final msg = MessageModel(
        id: "1",
        chatId: "chat",
        userId: "user",
        content: "short text",
        createdAt: baseDate,
        messageType: "text",
      );

      final output = msg.toString();
      expect(output, contains("short text"));
    });
  });
}
