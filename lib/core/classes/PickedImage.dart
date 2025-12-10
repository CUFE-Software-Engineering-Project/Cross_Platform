import 'dart:io' show File;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

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
      return PickedImage(
        file: File(image.path),
        name: image.name,
        path: image.path,
      );
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<List<PickedImage>> pickImages({int maxImages = 4}) async {
  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return [];

    return images.take(maxImages).map((image) {
      return PickedImage(
        file: File(image.path),
        name: image.name,
        path: image.path,
      );
    }).toList();
  } catch (e) {
    return [];
  }
}
