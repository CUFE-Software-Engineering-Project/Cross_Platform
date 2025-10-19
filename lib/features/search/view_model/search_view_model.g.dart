// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchViewModel)
const searchViewModelProvider = SearchViewModelProvider._();

final class SearchViewModelProvider
    extends $NotifierProvider<SearchViewModel, SearchState> {
  const SearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchViewModelHash();

  @$internal
  @override
  SearchViewModel create() => SearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchViewModelHash() => r'3b9f4cb58d93e52298e4e42513a2cac8bee5cf50';

abstract class _$SearchViewModel extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
