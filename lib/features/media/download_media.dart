import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> getMediaUrls(List<String> ids) async {
  print("start getting media---------*****");
  final container = ProviderContainer();

  // Fetch all media URLs in parallel
  final urlFutures = ids.map((id) async {
    try {
      final url = await container.read(mediaUrlProvider(id).future);
      print(url + "\n******************************");
      return url;
    } catch (e) {
      return "";
    }
  }).toList();

  // Wait for all requests to complete
  final urls = await Future.wait(urlFutures);

  container.dispose();
  print("end getting media---------*****" + urls[0]);
  return urls;
}
