// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExploreViewModel)
const exploreViewModelProvider = ExploreViewModelProvider._();

final class ExploreViewModelProvider
    extends $NotifierProvider<ExploreViewModel, ExploreState> {
  const ExploreViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreViewModelHash();

  @$internal
  @override
  ExploreViewModel create() => ExploreViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreState>(value),
    );
  }
}

String _$exploreViewModelHash() => r'4bd6515cfd7ddb9ea25af3e981e5fe72a24e4ad2';

abstract class _$ExploreViewModel extends $Notifier<ExploreState> {
  ExploreState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExploreState, ExploreState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExploreState, ExploreState>,
              ExploreState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
