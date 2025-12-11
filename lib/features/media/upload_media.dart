import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> upload_media(List<File> files) async {
  final container = ProviderContainer();
  final limitedFiles = files.take(4).toList();

  final List<String> ids = [];
  for (int i = 0; i < limitedFiles.length; i++) {
    final file = limitedFiles[i];
    bool fail = false;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileType = _getMediaType(file.path);

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
      ids.add("");
      continue;
    }

    // upload
    final upload = container.read(uploadProvider);
    final uploadResponse = await upload(requestUploadModel.url, file);
    uploadResponse.fold((l) {
      fail = true;
    }, (res) {});
    if (fail) {
      ids.add("");
      continue;
    }

    //confirm upload
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
      ids.add("");
      continue;
    }
    ids.add(confirmUploadModel.id);
  }

  container.dispose();
  return ids;
}

const Map<String, String> _mediaTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
};
String _getMediaType(String filePath) {
  final extension = filePath.split('.').last.toLowerCase();
  return _mediaTypes[extension] ?? 'image/jpeg';
}
