import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> upload_media(List<File> files) async {
  final container = ProviderContainer();

  List<String> ids = [];
  for (int i = 0; i < files.length; i++) {
    bool fail = false;

    // request upload
    final requestUpload = container.read(requestUploadProvider);
    final requestUploadResponse = await requestUpload("file$i.jpeg", "IMAGE");
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
    final uploadResponse = await upload(requestUploadModel.url, files[i]);
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
