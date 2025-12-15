// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationViewModel)
const notificationViewModelProvider = NotificationViewModelProvider._();

final class NotificationViewModelProvider
    extends
        $AsyncNotifierProvider<NotificationViewModel, List<NotificationItem>> {
  const NotificationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationViewModelHash();

  @$internal
  @override
  NotificationViewModel create() => NotificationViewModel();
}

String _$notificationViewModelHash() =>
    r'd42e2929b597c48fa2336e6266bc9465180abc34';

abstract class _$NotificationViewModel
    extends $AsyncNotifier<List<NotificationItem>> {
  FutureOr<List<NotificationItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<NotificationItem>>, List<NotificationItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationItem>>,
                List<NotificationItem>
              >,
              AsyncValue<List<NotificationItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
