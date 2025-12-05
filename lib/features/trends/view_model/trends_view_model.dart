import 'package:flutter/foundation.dart';

class TrendsViewModel extends ChangeNotifier {
  // Placeholder state and methods mirroring profile view model
  List<dynamic> trends = [];

  void loadTrends() {
    // TODO: implement loading logic
    trends = [];
    notifyListeners();
  }
}
