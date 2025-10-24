import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:lite_x/features/media/repositories/media_repository.dart';

class MediaViewModel {
  final Ref ref;
  MediaViewModel(this.ref);

  /// Upload file and attach it to [tweetId]. Returns backend response.
  Future<Map<String, dynamic>> attachMediaToTweet({
    required String tweetId,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final repo = ref.read(mediaRepositoryProvider);
    return await repo.attachMediaToTweet(tweetId: tweetId, fileBytes: Uint8List.fromList(fileBytes), filename: filename);
  }

  /// Retrieve media list attached to [tweetId].
  Future<List<Map<String, dynamic>>> getMediaForTweet(String tweetId) async {
    final repo = ref.read(mediaRepositoryProvider);
    return await repo.getMediaForTweet(tweetId: tweetId);
  }
}

final mediaViewModelProvider = Provider<MediaViewModel>((ref) {
  return MediaViewModel(ref);
});
