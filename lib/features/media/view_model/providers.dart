import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/media/repository/media_repo.dart';
import 'package:lite_x/features/media/repository/media_repo_impl.dart';

final mediaRepoProvider = Provider<MediaRepo>((ref) {
  return MediaRepoImpL(ref.watch(dioProvider));
});

final requestUploadProvider = Provider((ref) {
  final repo = ref.watch(mediaRepoProvider);
  return (String fileName, String fileType) {
    return repo.requestUpload(fileName, fileType);
  };
});

final confirmUploadProvider = Provider((ref) {
  final repo = ref.watch(mediaRepoProvider);
  return (String keyName) {
    return repo.confirmUpload(keyName);
  };
});

final uploadProvider = Provider((ref) {
  final repo = ref.watch(mediaRepoProvider);
  return (String uploadUrl, File mediaFile) {
    return repo.upload(uploadUrl, mediaFile);
  };
});

final mediaUrlProvider = FutureProvider.family<String, String>((ref, id) async {
  final repo = ref.watch(mediaRepoProvider);
  final res = await repo.getMediaUrl(id);
  return res.fold((failure) => "", (url) => url);
});
