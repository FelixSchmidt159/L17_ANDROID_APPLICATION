import 'package:flutter/foundation.dart';

import 'tour.dart';

class Applicant with ChangeNotifier {
  int id;
  String name;
  List<Tour> _tours;

  Applicant({
    @required this.name,
  });

  int overallDistance() {
    return 1253;
  }
}
