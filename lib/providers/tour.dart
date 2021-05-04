// import 'dart:convert';

import 'package:flutter/foundation.dart';

class Tour with ChangeNotifier {
  final String id;
  final DateTime timestamp;
  final int distance;
  final int mileageBegin;
  final int mileageEnd;
  final String licensePlate;
  final String tourBegin;
  final String tourEnd;
  final String roadCondition;
  final String attendant;

  Tour(
      {this.id,
      this.timestamp,
      this.distance,
      this.mileageBegin,
      this.mileageEnd,
      this.licensePlate,
      this.tourBegin,
      this.tourEnd,
      this.roadCondition,
      this.attendant});

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
