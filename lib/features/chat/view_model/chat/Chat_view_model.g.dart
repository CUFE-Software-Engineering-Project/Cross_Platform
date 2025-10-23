// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Chat_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatViewModel)
const chatViewModelProvider = ChatViewModelProvider._();

final class ChatViewModelProvider
    extends $NotifierProvider<ChatViewModel, AsyncValue<MessageModel>?> {
  const ChatViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatViewModelHash();

  @$internal
  @override
  ChatViewModel create() => ChatViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MessageModel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MessageModel>?>(value),
    );
  }
}

String _$chatViewModelHash() => r'1de41f392709bd3de3dcc0cec52f3839e720f991';

abstract class _$ChatViewModel extends $Notifier<AsyncValue<MessageModel>?> {
  AsyncValue<MessageModel>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<MessageModel>?, AsyncValue<MessageModel>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MessageModel>?, AsyncValue<MessageModel>?>,
              AsyncValue<MessageModel>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
