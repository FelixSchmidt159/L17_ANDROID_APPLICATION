import 'package:flutter/foundation.dart';

class Applicant with ChangeNotifier {
  String _id;
  String _name;

  Applicant(this._name, this._id);

  String get name {
    return _name;
  }

  String get id {
    return _id;
  }
}
