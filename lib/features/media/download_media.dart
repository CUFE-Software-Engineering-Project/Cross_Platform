import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> getMediaUrls(List<String> ids) async {
  // print("start getting media---------*****");
  final container = ProviderContainer();
  final List<String> urls = [];

  for (int i = 0; i < ids.length; i++) {
    try {
      final url = await container.read(mediaUrlProvider(ids[i]).future);
      urls.add(url);
    } catch (e) {
      urls.add("");
    }
  }

  // print(
  //   "end getting media---------***** ${urls.isNotEmpty ? urls[0] : 'empty'}",
  // );
  return urls;
}
