// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentions_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MentionsViewModel)
const mentionsViewModelProvider = MentionsViewModelProvider._();

final class MentionsViewModelProvider
    extends $AsyncNotifierProvider<MentionsViewModel, List<MentionItem>> {
  const MentionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentionsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mentionsViewModelHash();

  @$internal
  @override
  MentionsViewModel create() => MentionsViewModel();
}

String _$mentionsViewModelHash() => r'b4b7fee9bd14e0e9c5690b33009f2aff02480c2f';

abstract class _$MentionsViewModel extends $AsyncNotifier<List<MentionItem>> {
  FutureOr<List<MentionItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<MentionItem>>, List<MentionItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MentionItem>>, List<MentionItem>>,
              AsyncValue<List<MentionItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
