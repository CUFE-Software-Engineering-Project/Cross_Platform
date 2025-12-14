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
    r'0816b2401903ff8eb24b2e4d923e7f38fc29289a';

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
