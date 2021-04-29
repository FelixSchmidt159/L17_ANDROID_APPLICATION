import 'package:flutter/material.dart';
import 'package:l17/providers/applicant.dart';

class Applicants with ChangeNotifier {
  List<Applicant> _items = [
    Applicant(name: "Hans"),
    Applicant(name: "Christopherus"),
    Applicant(name: "Inuts")
  ];

  List<Applicant> get items {
    return [..._items];
  }
}
