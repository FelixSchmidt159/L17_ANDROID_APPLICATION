class Tour {
  DateTime timestamp;
  final int distance;
  final int mileageBegin;
  final int mileageEnd;
  final String licensePlate;
  final String tourBegin;
  final String tourEnd;
  final String roadCondition;
  final String attendant;
  final String daytime;
  final String weather;
  final String carName;
  final String id;

  Tour(
      {this.timestamp,
      this.distance,
      this.mileageBegin,
      this.mileageEnd,
      this.licensePlate,
      this.tourBegin,
      this.tourEnd,
      this.roadCondition,
      this.attendant,
      this.daytime,
      this.weather,
      this.id,
      this.carName});
}
