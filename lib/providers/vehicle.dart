class Vehicle {
  String _id;
  String _name;
  String _licensePlate;

  Vehicle(
    this._name,
    this._licensePlate,
    this._id,
  );

  String get name {
    return _name;
  }

  String get id {
    return _id;
  }

  String get licensePlate {
    return _licensePlate;
  }
}
