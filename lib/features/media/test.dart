import 'dart:io';

void main() async {
  List<File> files = [];
  files.add(File("./images.jpeg"));
  print(files[0].path);
}
