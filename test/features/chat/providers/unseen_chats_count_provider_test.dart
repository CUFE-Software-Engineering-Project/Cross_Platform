import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/unseenChatsCountProvider.dart';

void main() {
  test('unseenChatsCountProvider initializes to 0 and updates correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(unseenChatsCountProvider), 0);
    container.read(unseenChatsCountProvider.notifier).state = 5;
    expect(container.read(unseenChatsCountProvider), 5);

    container.read(unseenChatsCountProvider.notifier).state++;
    expect(container.read(unseenChatsCountProvider), 6);
  });
}
