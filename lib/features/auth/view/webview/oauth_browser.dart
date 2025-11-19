import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OAuthInAppBrowser extends InAppBrowser {
  final String successBaseUrl;
  final Completer<Map<String, String>> completer;

  OAuthInAppBrowser({required this.successBaseUrl, required this.completer});

  @override
  void onLoadStart(Uri? url) {
    final current = url.toString();

    if (current.startsWith(successBaseUrl)) {
      try {
        final uri = Uri.parse(current);

        final token = uri.queryParameters["token"];
        final refresh = uri.queryParameters["refresh-token"];
        final userRaw = uri.queryParameters["user"];

        if (token != null && refresh != null && userRaw != null) {
          webViewController?.stopLoading();
          close();

          completer.complete({
            "token": token,
            "refresh": refresh,
            "user": userRaw,
          });
        }
      } catch (e) {
        // ignore
      }
    }
  }

  @override
  void onExit() {
    if (!completer.isCompleted) {
      completer.completeError("USER_CLOSED");
    }
  }
}

class OAuthBrowser {
  final String startUrl;
  final String successBaseUrl;

  OAuthBrowser({required this.startUrl, required this.successBaseUrl});

  Future<Map<String, String>> start() async {
    final completer = Completer<Map<String, String>>();

    final browser = OAuthInAppBrowser(
      successBaseUrl: successBaseUrl,
      completer: completer,
    );

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(startUrl)),
      options: InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          hideToolbarTop: true,
          hideUrlBar: true,
        ),
      ),
    );

    return completer.future;
  }
}
