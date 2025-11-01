import 'dart:io' show File;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PickedImage {
  final File? file;
  final Uint8List? bytes;
  final String name;
  final String? path;
  PickedImage({this.file, this.bytes, required this.name, this.path});
}

Future<PickedImage?> pickImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return PickedImage(bytes: bytes, name: image.name, path: image.path);
      } else {
        return PickedImage(
          file: File(image.path),
          name: image.name,
          path: image.path,
        );
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}
