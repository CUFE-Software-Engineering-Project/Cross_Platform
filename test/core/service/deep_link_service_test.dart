import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/services/deep_link_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'deep_link_service_test.mocks.dart';

@GenerateMocks([AppLinks])
void main() {
  late MockAppLinks mockAppLinks;
  late StreamController<Uri> uriController;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAppLinks = MockAppLinks();
    uriController = StreamController<Uri>.broadcast();
    when(mockAppLinks.uriLinkStream).thenAnswer((_) => uriController.stream);
    DeepLinkService.appLinksInstance = mockAppLinks;
    DeepLinkService.init();
  });

  tearDown(() {
    uriController.close();
    DeepLinkService.cancel();
  });

  group('DeepLinkService Tests', () {
    test('waitForLink should return Uri when stream emits a value', () async {
      final expectedUri = Uri.parse('https://example.com/test');
      final future = DeepLinkService.waitForLink();
      uriController.add(expectedUri);
      expect(await future, expectedUri);
    });

    test('cancel should complete the future with null', () async {
      final future = DeepLinkService.waitForLink();
      DeepLinkService.cancel();
      expect(await future, isNull);
    });

    test('should return the same instance (Singleton pattern)', () {
      final instance1 = DeepLinkService();
      final instance2 = DeepLinkService();
      expect(instance1, same(instance2));
      expect(identical(instance1, instance2), isTrue);
    });
    test(
      'Should complete with null if app resumes and times out (Lifecycle Test)',
      () {
        fakeAsync((async) {
          final future = DeepLinkService.waitForLink();
          bool isCompleted = false;
          future.then((_) => isCompleted = true);
          TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          async.elapse(const Duration(milliseconds: 500));
          expect(
            isCompleted,
            isFalse,
            reason: 'Should not complete before 1000ms',
          );
          async.elapse(const Duration(milliseconds: 501));
          expect(isCompleted, isTrue, reason: 'Should complete after 1000ms');
        });
      },
    );

    test('Should ignore events if completer is already completed', () async {
      final uri1 = Uri.parse('https://first.com');
      final uri2 = Uri.parse('https://second.com');
      final future = DeepLinkService.waitForLink();
      uriController.add(uri1);
      final result = await future;
      expect(result, uri1);
      uriController.add(uri2);
    });
  });
}
