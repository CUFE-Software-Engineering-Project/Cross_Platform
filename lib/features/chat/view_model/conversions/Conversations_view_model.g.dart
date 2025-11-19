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
          AsyncValue<List<ConversationModel>>
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
  Override overrideWithValue(AsyncValue<List<ConversationModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ConversationModel>>>(
        value,
      ),
    );
  }
}

String _$conversationsViewModelHash() =>
    r'f2272c5b5df4528a2eb5f9712a76021a00b1f2da';

abstract class _$ConversationsViewModel
    extends $Notifier<AsyncValue<List<ConversationModel>>> {
  AsyncValue<List<ConversationModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ConversationModel>>,
              AsyncValue<List<ConversationModel>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ConversationModel>>,
                AsyncValue<List<ConversationModel>>
              >,
              AsyncValue<List<ConversationModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
