import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

void main() {
  late Directory tempDir;
  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(MessageModelAdapter());
  });

  tearDownAll(() {
    try {
      Hive.close();
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('put/get from box should preserve MessageModel', () async {
    final box = await Hive.openBox<MessageModel>('testBox');
    final message = MessageModel(
      id: "1",
      chatId: "chat1",
      userId: "user1",
      content: "Hello from hive",
      createdAt: DateTime(2025, 1, 1, 12, 0),
      status: "SENT",
      senderUsername: "aser",
      senderName: "Aser",
      senderProfileMediaKey: "key_1",
      messageType: "text",
    );

    await box.put(message.id, message);
    final got = box.get(message.id);

    expect(got, isNotNull);
    expect(got!.id, message.id);
    expect(got.chatId, message.chatId);
    expect(got.content, message.content);

    await box.deleteFromDisk();
  });
  test('read method execution forces deserialization from disk', () async {
    var box = await Hive.openBox<MessageModel>('diskTestBox');
    final message = MessageModel(
      id: "disk_id_1",
      chatId: "chat_disk",
      userId: "user_disk",
      content: "Disk read test",
      createdAt: DateTime.now(),
      status: "SENT",
      messageType: "text",
    );

    await box.put(message.id, message);

    await box.close();

    box = await Hive.openBox<MessageModel>('diskTestBox');

    final result = box.get("disk_id_1");

    expect(result, isNotNull);
    expect(result!.content, "Disk read test");

    await box.deleteFromDisk();
  });
  test('MessageModelAdapter equality', () {
    final a1 = MessageModelAdapter();
    final a2 = MessageModelAdapter();

    expect(a1 == a2, true);
    expect(a1.hashCode, a2.hashCode);

    expect(a1 == 'string', false);
  });
}
