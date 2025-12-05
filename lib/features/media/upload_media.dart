import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/models/shared.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> upload_media(List<File> files) async {
  final container = ProviderContainer();
  final limitedFiles = files.take(4).toList();

  // Process all files in parallel
  final uploadFutures = limitedFiles.map((file) async {
    bool fail = false;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileType = getMediaType(file.path);

    // request upload
    final requestUpload = container.read(requestUploadProvider);
    final requestUploadResponse = await requestUpload(fileName, fileType);
    RequestUploadModel requestUploadModel = RequestUploadModel(
      url: "",
      keyName: "",
    );
    requestUploadResponse.fold(
      (l) {
        fail = true;
      },
      (res) {
        requestUploadModel = res;
      },
    );
    if (fail) {
      return "";
    }

    // upload
    final upload = container.read(uploadProvider);
    final uploadResponse = await upload(requestUploadModel.url, file);
    uploadResponse.fold((l) {
      fail = true;
    }, (res) {});
    if (fail) {
      return "";
    }

    // confirm upload
    final confirmUpload = container.read(confirmUploadProvider);
    final confirmUploadResponse = await confirmUpload(
      requestUploadModel.keyName,
    );
    ConfirmUploadModel confirmUploadModel = ConfirmUploadModel(
      id: "",
      name: "",
      keyName: "",
      type: "",
      size: 0,
    );
    confirmUploadResponse.fold(
      (l) {
        fail = true;
      },
      (res) {
        confirmUploadModel = res;
      },
    );
    if (fail) {
      return "";
    }
    return confirmUploadModel.id;
  }).toList();

  // Wait for all uploads to complete
  final ids = await Future.wait(uploadFutures);

  container.dispose();
  return ids;
}
