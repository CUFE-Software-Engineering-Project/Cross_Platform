// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentioned_tweets_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MentionedTweetsViewModel)
const mentionedTweetsViewModelProvider = MentionedTweetsViewModelFamily._();

final class MentionedTweetsViewModelProvider
    extends $NotifierProvider<MentionedTweetsViewModel, MentionedTweetsState> {
  const MentionedTweetsViewModelProvider._({
    required MentionedTweetsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mentionedTweetsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mentionedTweetsViewModelHash();

  @override
  String toString() {
    return r'mentionedTweetsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MentionedTweetsViewModel create() => MentionedTweetsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MentionedTweetsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MentionedTweetsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MentionedTweetsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mentionedTweetsViewModelHash() =>
    r'fa7026c94c3f20e11b7c8df4b605ab6e937e2444';

final class MentionedTweetsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          MentionedTweetsViewModel,
          MentionedTweetsState,
          MentionedTweetsState,
          MentionedTweetsState,
          String
        > {
  const MentionedTweetsViewModelFamily._()
    : super(
        retry: null,
        name: r'mentionedTweetsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MentionedTweetsViewModelProvider call(String username) =>
      MentionedTweetsViewModelProvider._(argument: username, from: this);

  @override
  String toString() => r'mentionedTweetsViewModelProvider';
}

abstract class _$MentionedTweetsViewModel
    extends $Notifier<MentionedTweetsState> {
  late final _$args = ref.$arg as String;
  String get username => _$args;

  MentionedTweetsState build(String username);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<MentionedTweetsState, MentionedTweetsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MentionedTweetsState, MentionedTweetsState>,
              MentionedTweetsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
