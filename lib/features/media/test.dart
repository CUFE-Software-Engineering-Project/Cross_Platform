import 'dart:io';
import 'package:file_picker/file_picker.dart';

void main() async {
  List<File> files = [];
  files.add(File("./images.jpeg"));
  print(files[0].path);
}
