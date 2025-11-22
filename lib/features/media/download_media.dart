import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/view_model/providers.dart';

Future<List<String>> getMediaUrls(List<String> ids) async {
  final container = ProviderContainer();
  final List<String> urls = [];
  for (int i = 0; i < ids.length; i++) {
    final download = container.read(getMedialUrlProvider);
    final res = await download(ids[i]);

    res.fold(
      (l) {
        urls.add("");
      },
      (url) {
        urls.add(url);
      },
    );
  }

  container.dispose();
  return urls;
}
