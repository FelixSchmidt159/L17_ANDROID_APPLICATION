// import 'dart:convert';

import 'package:flutter/foundation.dart';

class Tour with ChangeNotifier {
  final DateTime timestamp;
  final int distance;
  final int mileageBegin;
  final int mileageEnd;
  final String licensePlate;
  final String tourBegin;
  final String tourEnd;
  final String roadCondition;

  Tour({
    @required this.timestamp,
    @required this.distance,
    @required this.mileageBegin,
    @required this.mileageEnd,
    @required this.licensePlate,
    @required this.tourBegin,
    @required this.tourEnd,
    @required this.roadCondition,
  });

  // void _setFavValue(bool newValue) {
  //   isFavorite = newValue;
  //   notifyListeners();
  // }

  // Future<void> toggleFavoriteStatus() async {
  //   final oldStatus = isFavorite;
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  //   final url = 'https://flutter-update.firebaseio.com/products/$id.json';
  //   try {
  //     final response = await http.patch(
  //       url,
  //       body: json.encode({
  //         'isFavorite': isFavorite,
  //       }),
  //     );
  //     if (response.statusCode >= 400) {
  //       _setFavValue(oldStatus);
  //     }
  //   } catch (error) {
  //     _setFavValue(oldStatus);
  //   }
  // }
}
