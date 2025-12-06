import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activeChatIdProvider.g.dart';

@riverpod
class ActiveChat extends _$ActiveChat {
  @override
  String? build() => null;

  void setActive(String? id) => state = id;
}
