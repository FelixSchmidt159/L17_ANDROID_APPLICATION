import 'package:flutter/material.dart';

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
