// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatLocalRepository)
const chatLocalRepositoryProvider = ChatLocalRepositoryProvider._();

final class ChatLocalRepositoryProvider
    extends
        $FunctionalProvider<
          ChatLocalRepository,
          ChatLocalRepository,
          ChatLocalRepository
        >
    with $Provider<ChatLocalRepository> {
  const ChatLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatLocalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatLocalRepository create(Ref ref) {
    return chatLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatLocalRepository>(value),
    );
  }
}

String _$chatLocalRepositoryHash() =>
    r'1609067a20be30b0ba734f66d45523e2d3e0ed2d';
