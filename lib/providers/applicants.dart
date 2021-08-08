import 'package:flutter/material.dart';

/// represents an provider, which can be subscribed to
/// if _selectedDriverId changes, subscribers will be notified
class Applicants with ChangeNotifier {
  String _selectedDriverId;

  Applicants();
  String get selectedDriverId {
    return _selectedDriverId;
  }

  set selectedDriverId(String selectedDriverId) {
    _selectedDriverId = selectedDriverId;
    notifyListeners();
  }
}
