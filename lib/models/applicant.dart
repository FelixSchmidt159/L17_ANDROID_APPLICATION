class Applicant {
  String _id;
  String _name;

  /// id represents the unique identification given from firebase
  /// name represents the name of the applicant/driver
  Applicant(this._name, this._id);

  String get name => _name;
  String get id => _id;
}
