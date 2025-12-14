// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static Completer<Uri?>? _completer;
  static final AppLinks _appLinks = AppLinks();

  static final _AppLifecycleObserver _observer = _AppLifecycleObserver();

  static void init() {
    _appLinks.uriLinkStream.listen((uri) {
      log("🔵 DeepLinkService received URI: $uri");

      if (uri != null && _completer != null && !_completer!.isCompleted) {
        log("🟢 Completing deep link future with: $uri");
        _completer!.complete(uri);
      }
    });

    WidgetsBinding.instance.addObserver(_observer);
  }

  static Future<Uri?> waitForLink() {
    _completer = Completer<Uri?>();
    return _completer!.future;
  }

  static void cancel() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (DeepLinkService._completer != null &&
            !DeepLinkService._completer!.isCompleted) {
          DeepLinkService._completer!.complete(null);
        }
      });
    }
  }
}
