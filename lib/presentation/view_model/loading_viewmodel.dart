import 'package:flutter/foundation.dart' show ChangeNotifier;

// This class is used to notify the UI when the loading state changes
class LoadingViewModel with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
