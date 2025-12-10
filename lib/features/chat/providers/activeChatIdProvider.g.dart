// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activeChatIdProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveChat)
const activeChatProvider = ActiveChatProvider._();

final class ActiveChatProvider extends $NotifierProvider<ActiveChat, String?> {
  const ActiveChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChatHash();

  @$internal
  @override
  ActiveChat create() => ActiveChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeChatHash() => r'23f0395134ca4d8af5a88f7ad3482566e0783170';

abstract class _$ActiveChat extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
