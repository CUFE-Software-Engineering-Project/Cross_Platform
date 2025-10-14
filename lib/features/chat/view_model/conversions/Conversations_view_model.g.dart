// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Conversations_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationsViewModel)
const conversationsViewModelProvider = ConversationsViewModelProvider._();

final class ConversationsViewModelProvider
    extends
        $NotifierProvider<
          ConversationsViewModel,
          AsyncValue<ConversationModel>?
        > {
  const ConversationsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsViewModelHash();

  @$internal
  @override
  ConversationsViewModel create() => ConversationsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ConversationModel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ConversationModel>?>(
        value,
      ),
    );
  }
}

String _$conversationsViewModelHash() =>
    r'f38f8ce0224254568b8c9ac00d11f62babffaedd';

abstract class _$ConversationsViewModel
    extends $Notifier<AsyncValue<ConversationModel>?> {
  AsyncValue<ConversationModel>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ConversationModel>?,
              AsyncValue<ConversationModel>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ConversationModel>?,
                AsyncValue<ConversationModel>?
              >,
              AsyncValue<ConversationModel>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
