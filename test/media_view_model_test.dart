import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/features/media/repositories/media_repository.dart';
import 'package:lite_x/features/media/view_model/media_view_model.dart';

class FakeMediaRepository extends MediaRepository {
  FakeMediaRepository() : super(dio: Dio(BASE_OPTIONS));

  @override
  Future<Map<String, dynamic>> attachMediaToTweet({required String tweetId, required Uint8List fileBytes, required String filename}) async {
    return {'ok': true, 'id': 'media-123', 'filename': filename};
  }

  @override
  Future<List<Map<String, dynamic>>> getMediaForTweet({required String tweetId}) async {
    return [
      {'id': 'media-123', 'url': 'https://example.com/media-123.jpg'}
    ];
  }
}

void main() {
  test('media view model attachMediaToTweet uses repo', () async {
    final fake = FakeMediaRepository();
    final container = ProviderContainer(overrides: [
      mediaRepositoryProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    final vm = container.read(mediaViewModelProvider);
    expect(vm, isNotNull);

    final resp = await vm.attachMediaToTweet(tweetId: 't1', fileBytes: Uint8List.fromList([0, 1, 2]), filename: 'a.png');
    expect(resp['ok'], true);
    expect(resp['filename'], 'a.png');
  });
}
