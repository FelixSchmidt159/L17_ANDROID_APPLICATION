import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:l17/providers/vehicle.dart';
import 'package:provider/provider.dart';

class TourScreen extends StatefulWidget {
  static const routeName = '/tour-screen';

  @override
  _TourScreenState createState() => _TourScreenState();
}

enum LifeSearch { attendants, locations, licensePlates }

class _TourScreenState extends State<TourScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  TourScreenArguments tourObject;

  final _form = GlobalKey<FormState>();
  final TextEditingController _typeAheadControllerLicensePlate =
      TextEditingController();
  final TextEditingController _typeAheadControllerTourBegin =
      TextEditingController();
  final TextEditingController _typeAheadControllerTourEnd =
      TextEditingController();
  final TextEditingController _typeAheadControllerAttendant =
      TextEditingController();
  final TextEditingController _mileageBegin = TextEditingController();
  final TextEditingController _mileageEnd = TextEditingController();
  TextEditingController _initialDate = TextEditingController();
  TextEditingController _dayTime = TextEditingController();
  TextEditingController _distance = TextEditingController();
  List<String> _attendants = [];
  List<String> _locations = [];
  List<String> _licensePlates = [];
  String suggestedAttendant = "";
  String suggestedRoadCondition = "trocken";
  String suggestedWeather = "heiter";
  String suggestedLicensePlate = "";
  bool _initializeArguments = true;
  bool _initializeVehicles = true;
  bool _initializeSuggestions = true;
  String _selectedDriver;
  List<Vehicle> vehicles = [];
  bool fieldsHaveChanged = false;
  List<DropdownMenuItem<String>> _dropdownMenuItemList = [];
  StreamSubscription<QuerySnapshot> _vehicleListener;
  String _vehicleName = "";
  DateTime dateTime = DateTime.now();

  @override
  void dispose() {
    if (_vehicleListener != null) _vehicleListener.cancel();
    _dayTime.dispose();
    _typeAheadControllerLicensePlate.dispose();
    _typeAheadControllerTourBegin.dispose();
    _typeAheadControllerTourEnd.dispose();
    _typeAheadControllerAttendant.dispose();
    _initialDate.dispose();
    _mileageBegin.dispose();
    _mileageEnd.dispose();
    _distance.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
      tourObject =
          ModalRoute.of(context).settings.arguments as TourScreenArguments;
    }

    if (_initializeArguments) {
      suggestedRoadCondition = tourObject.tour.roadCondition == ""
          ? "trocken"
          : tourObject.tour.roadCondition;
      suggestedWeather =
          tourObject.tour.weather == "" ? "heiter" : tourObject.tour.weather;
      _typeAheadControllerTourBegin.text = tourObject.tour.tourBegin;
      _typeAheadControllerTourEnd.text = tourObject.tour.tourEnd;
      _typeAheadControllerAttendant.text = tourObject.tour.attendant;
      _dayTime.text = tourObject.tour.daytime;
      _vehicleName = tourObject.tour.carName;
      _typeAheadControllerLicensePlate.text = tourObject.tour.licensePlate;
      _initialDate.text =
          DateFormat.yMMMd('de_DE').format(tourObject.tour.timestamp);
      dateTime = tourObject.tour.timestamp;
      _mileageEnd.text = tourObject.tour.mileageEnd == 0
          ? ""
          : tourObject.tour.mileageEnd.toString();
      _mileageBegin.text = tourObject.tour.mileageBegin == 0
          ? ""
          : tourObject.tour.mileageBegin.toString();
      _distance.text = tourObject.tour.distance == 0
          ? ""
          : tourObject.tour.distance.toString();
      _initializeArguments = false;
    }

    if (_selectedDriver != null && _initializeSuggestions) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .get()
          .then(
        (value) {
          final toursDocs = value.docs;
          if (toursDocs.isNotEmpty) {
            for (int i = 0; i < toursDocs.length; i++) {
              if (toursDocs[i]['licensePlate'] != "")
                _licensePlates.add(toursDocs[i]['licensePlate']);
              if (toursDocs[i]['attendant'] != "")
                _attendants.add(toursDocs[i]['attendant']);
              if (toursDocs[i]['tourBegin'] != "")
                _locations.add(toursDocs[i]['tourBegin']);
              if (toursDocs[i]['tourEnd'] != "")
                _locations.add(toursDocs[i]['tourEnd']);
              if (i == 0) {
                suggestedAttendant = toursDocs[i]['attendant'];
                suggestedLicensePlate = toursDocs[i]['licensePlate'];
              }
            }
            _locations = _locations.toSet().toList();
            _attendants = _attendants.toSet().toList();
            _licensePlates = _licensePlates.toSet().toList();

            if (tourObject.id == "") {
              if (mounted) {
                setState(() {
                  fieldsHaveChanged = true;
                  if (tourObject.tour.licensePlate == "") {
                    _typeAheadControllerLicensePlate.text =
                        suggestedLicensePlate;
                  }
                  if (_typeAheadControllerAttendant.text == "") {
                    _typeAheadControllerAttendant.text = suggestedAttendant;
                  }
                });
              }
            }
          }
        },
      );
      _initializeSuggestions = false;
    }
    if (_initializeVehicles) {
      bool found = true;
      _vehicleListener = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('vehicles')
          .snapshots()
          .listen((event) {
        vehicles = [];
        _dropdownMenuItemList = [];
        final toursDocs = event.docs;
        if (toursDocs.isNotEmpty) {
          found = false;
          for (int i = 0; i < toursDocs.length; i++) {
            vehicles.add(Vehicle(toursDocs[i]['name'],
                toursDocs[i]['licensePlate'], toursDocs[i].id));
            if (_vehicleName == toursDocs[i]['name']) found = true;
          }
          _dropdownMenuItemList =
              vehicles.map<DropdownMenuItem<String>>((Vehicle vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle.name,
              child: SizedBox(
                child: Text(
                  vehicle.name,
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList();

          if (mounted) {
            setState(() {});
          }
        }
        if (!found)
          _dropdownMenuItemList.add(DropdownMenuItem<String>(
            value: _vehicleName,
            child: SizedBox(
              child: Text(
                _vehicleName,
                style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ));
      });
      _initializeVehicles = false;
    }

    super.didChangeDependencies();
  }

  Future<bool> _saveForm() async {
    int vehicleIdIndex = 0;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return false;
    }
    for (int i = 0; i < vehicles.length; i++) {
      if (vehicles[i].name.toLowerCase() == _vehicleName.toLowerCase()) {
        vehicleIdIndex = i;
        break;
      }
    }
    if (_selectedDriver != null) {
      if (tourObject.id == "") {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('tours')
            .add({
          'timestamp': dateTime,
          'distance': num.tryParse(_distance.text) == null
              ? 0
              : int.parse(_distance.text),
          'mileageBegin': num.tryParse(_mileageBegin.text) == null
              ? 0
              : int.parse(_mileageBegin.text),
          'mileageEnd': num.tryParse(_mileageEnd.text) == null
              ? 0
              : int.parse(_mileageEnd.text),
          'licensePlate': _typeAheadControllerLicensePlate.text,
          'tourBegin': _typeAheadControllerTourBegin.text,
          'tourEnd': _typeAheadControllerTourEnd.text,
          'roadCondition': suggestedRoadCondition,
          'attendant': _typeAheadControllerAttendant.text,
          'daytime': _dayTime.text,
          'weather': suggestedWeather,
          'carName': _vehicleName,
        }).catchError((e) => print(e));
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('tours')
            .doc(tourObject.id)
            .update({
          'timestamp': dateTime,
          'distance': num.tryParse(_distance.text) == null
              ? 0
              : int.parse(_distance.text),
          'mileageBegin': num.tryParse(_mileageBegin.text) == null
              ? 0
              : int.parse(_mileageBegin.text),
          'mileageEnd': num.tryParse(_mileageEnd.text) == null
              ? 0
              : int.parse(_mileageEnd.text),
          'licensePlate': _typeAheadControllerLicensePlate.text,
          'tourBegin': _typeAheadControllerTourBegin.text,
          'tourEnd': _typeAheadControllerTourEnd.text,
          'roadCondition': suggestedRoadCondition,
          'attendant': _typeAheadControllerAttendant.text,
          'daytime': _dayTime.text,
          'weather': suggestedWeather,
          'carName': _vehicleName,
        }).catchError((e) => print(e));
      }
      if (vehicleIdIndex < vehicles.length &&
          vehicles[vehicleIdIndex].name.toLowerCase() ==
              _vehicleName.toLowerCase() &&
          vehicles[vehicleIdIndex].licensePlate.toLowerCase() ==
              _typeAheadControllerLicensePlate.text.toLowerCase()) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('vehicles')
            .doc(vehicles[vehicleIdIndex].id)
            .update({
          'lastMileage': num.tryParse(_mileageEnd.text) == null
              ? 0
              : int.parse(_mileageEnd.text),
          'name': vehicles[vehicleIdIndex].name,
          'licensePlate': vehicles[vehicleIdIndex].licensePlate,
        }).catchError((e) => print(e));
        ;
        return true;
      } else {
        return true;
      }
    } else if (_selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fügen Sie vorerst einen neuen Fahrer hinzu.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return true;
    } else {
      return true;
    }
  }

  List<String> getSuggestions(
    String pattern,
    LifeSearch lifeSearchType,
  ) {
    List<String> suggestions = [];
    List<String> possibleSuggestions = [];
    switch (lifeSearchType) {
      case LifeSearch.attendants:
        {
          possibleSuggestions = _attendants;
        }
        break;
      case LifeSearch.licensePlates:
        {
          possibleSuggestions = _licensePlates;
        }
        break;
      case LifeSearch.locations:
        {
          possibleSuggestions = _locations;
        }
        break;
    }
    for (String str in possibleSuggestions) {
      if (str.toLowerCase().contains(pattern.toLowerCase())) {
        suggestions.add(str);
      }
    }

    if (lifeSearchType == LifeSearch.licensePlates) {
      for (int i = 0; i < vehicles.length; i++) {
        suggestions.add(vehicles[i].licensePlate);
      }
    }

    suggestions = suggestions.toSet().toList();
    if (suggestions.length >= 3) {
      List<String> limitedSuggestions = [];
      for (int i = 0; i < 3; i++) limitedSuggestions.add(suggestions[i]);
      suggestions = limitedSuggestions;
    }
    return suggestions;
  }

  Future<DateTime> _selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  Future<TimeOfDay> _selectTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(_dayTime.text.split(':')[0]),
          minute: int.parse(_dayTime.text.split(':')[1])),
    );
  }

  // Future<bool> _onWillPop() async {
  //   if (!fieldsHaveChanged) return true;
  //   return (await showDialog(
  //         context: context,
  //         builder: (context) => new AlertDialog(
  //           title: Text(
  //             'Die Änderungen wurden nicht gespeichert.',
  //           ),
  //           content: Text('Wollen Sie die Änderungen verwerfen?'),
  //           actions: <Widget>[
  //             TextButton(
  //               style: TextButton.styleFrom(
  //                   backgroundColor: Colors.green, primary: Colors.white),
  //               onPressed: () {
  //                 Navigator.of(context).pop(true);
  //               },
  //               child: new Text('Ja'),
  //             ),
  //             TextButton(
  //               style: TextButton.styleFrom(
  //                   backgroundColor: Colors.red, primary: Colors.white),
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: new Text('Nein'),
  //             ),
  //           ],
  //         ),
  //       )) ??
  //       false;
  // }

  Future<bool> _onWillPop() async {
    return (_saveForm()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tour'),
            actions: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.save),
              //   onPressed: _saveForm,
              // ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Start',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        TypeAheadFormField(
                          key: Key('Startort'),
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(labelText: 'Ort'),
                              keyboardType: TextInputType.text,
                              controller: _typeAheadControllerTourBegin,
                              onChanged: (value) {
                                fieldsHaveChanged = true;
                              }),
                          noItemsFoundBuilder: (context) {
                            return SizedBox();
                          },
                          validator: (value) {
                            if (value != null && value.length > 20)
                              return 'Geben Sie maximal 20 Zeichen ein.';
                            return null;
                          },
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern, LifeSearch.locations);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadControllerTourBegin.text =
                                suggestion;
                          },
                        ),
                        Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: <Widget>[
                              TextFormField(
                                controller: _mileageBegin,
                                decoration: InputDecoration(
                                  labelText: 'Kilometerstand',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.isNotEmpty &&
                                      num.tryParse(value) == null) {
                                    return 'Geben Sie bitte eine ganze Zahl ein.';
                                  }
                                  if (value != null && value.length > 7)
                                    return 'Geben Sie maximal 7 Zeichen ein.';
                                  if (num.tryParse(value) != null &&
                                      int.parse(value) < 0)
                                    return 'Sie können nur positive Zahlen als Ziel definieren.';
                                  if (_distance.text != null &&
                                      num.tryParse(_distance.text) != null &&
                                      int.parse(_distance.text) >= 65000)
                                    return 'Die maximale Distanz beträgt 65000km';
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      num.tryParse(value) != null &&
                                      num.tryParse(_mileageEnd.text) != null) {
                                    if (int.parse(_mileageEnd.text) >=
                                        int.parse(value)) {
                                      setState(() {
                                        var test = int.parse(_mileageEnd.text) -
                                            int.parse(value);
                                        _distance.text = test.toString();
                                      });
                                    } else {
                                      _distance.text = "";
                                    }
                                  }
                                  if (value.isEmpty ||
                                      _mileageBegin.text.isEmpty) {
                                    _distance.text = "";
                                  }

                                  fieldsHaveChanged = true;
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                ),
                                onPressed: () {
                                  _pickImage(true);
                                },
                              ),
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ziel',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        TypeAheadFormField(
                          key: Key('ZielOrt'),
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(labelText: 'Ort'),
                              keyboardType: TextInputType.text,
                              controller: _typeAheadControllerTourEnd,
                              onChanged: (value) {
                                fieldsHaveChanged = true;
                              }),
                          noItemsFoundBuilder: (context) {
                            return SizedBox();
                          },
                          validator: (value) {
                            if (value != null && value.length > 20)
                              return 'Geben Sie maximal 20 Zeichen ein.';
                            return null;
                          },
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern, LifeSearch.locations);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadControllerTourEnd.text = suggestion;
                          },
                        ),
                        Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: <Widget>[
                              TextFormField(
                                controller: _mileageEnd,
                                decoration: InputDecoration(
                                    labelText: 'Kilometerstand'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.isNotEmpty &&
                                      num.tryParse(value) == null) {
                                    return 'Geben Sie bitte eine ganze Zahl ein.';
                                  }
                                  if (value != null && value.length > 7)
                                    return 'Geben Sie maximal 7 Zeichen ein.';
                                  if (num.tryParse(value) != null &&
                                      int.parse(value) < 0)
                                    return 'Sie können nur positive Zahlen als Ziel definieren.';
                                  if (_distance.text != null &&
                                      num.tryParse(_distance.text) != null &&
                                      int.parse(_distance.text) >= 65000)
                                    return 'Die maximale Distanz beträgt 65000km';
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      num.tryParse(value) != null &&
                                      num.tryParse(_mileageBegin.text) !=
                                          null) {
                                    if (int.parse(value) >=
                                        int.parse(_mileageBegin.text)) {
                                      setState(() {
                                        var test = int.parse(value) -
                                            int.parse(_mileageBegin.text);
                                        _distance.text = test.abs().toString();
                                      });
                                    } else {
                                      _distance.text = "";
                                    }
                                  }
                                  if (value.isEmpty ||
                                      _mileageBegin.text.isEmpty) {
                                    _distance.text = "";
                                  }

                                  fieldsHaveChanged = true;
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                ),
                                onPressed: () {
                                  _pickImage(false);
                                },
                              ),
                            ]),
                        IgnorePointer(
                          child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Distanz',
                                // fillColor: Colors.grey.shade300,
                                // filled: true,
                                enabled: false,
                              ),
                              keyboardType: TextInputType.number,
                              controller: _distance,
                              validator: (value) {
                                if (value != null &&
                                    num.tryParse(value) != null &&
                                    int.parse(value) >= 65000)
                                  return 'Die maximale Distanz beträgt 65000km';
                                return null;
                              },
                              onChanged: (value) {
                                fieldsHaveChanged = true;
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Wetter',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonFormField<String>(
                          decoration:
                              InputDecoration(labelText: 'Straßenzustand'),
                          items: ['nass', 'trocken', 'eisig', 'schneebedeckt']
                              .map((label) => DropdownMenuItem(
                                    child: Text(label),
                                    value: label,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              fieldsHaveChanged = true;
                              suggestedRoadCondition = value;
                            });
                          },
                          key: Key('condition'),
                          value: suggestedRoadCondition,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Witterung'),
                          items: [
                            'wechselhaft',
                            'wolkenfrei',
                            'bewölkt',
                            'regnerisch',
                            'stürmisch',
                            'nebelig',
                            'heiter'
                          ]
                              .map((label) => DropdownMenuItem(
                                    child: Text(label),
                                    value: label,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              fieldsHaveChanged = true;
                              suggestedWeather = value;
                            });
                          },
                          key: Key('weather'),
                          value: suggestedWeather,
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Fahrzeug',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration:
                                  InputDecoration(labelText: 'Begleiter'),
                              controller: _typeAheadControllerAttendant,
                              onChanged: (value) {
                                fieldsHaveChanged = true;
                              }),
                          noItemsFoundBuilder: (context) {
                            return SizedBox();
                          },
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern, LifeSearch.attendants);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          validator: (value) {
                            if (value != null && value.length > 20)
                              return 'Geben Sie maximal 20 Zeichen ein.';
                            return null;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadControllerAttendant.text =
                                suggestion;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          iconDisabledColor: Colors.grey.shade200,
                          decoration:
                              InputDecoration(labelText: 'Fahrzeugname'),
                          disabledHint: SizedBox(
                            child: Text(
                              _vehicleName,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          value: _vehicleName,
                          onChanged: _dropdownMenuItemList.length > 0
                              ? (String value) {
                                  if (value != null) {
                                    setState(() {
                                      _vehicleName = value;
                                      for (int i = 0;
                                          i < vehicles.length;
                                          i++) {
                                        if (vehicles[i].name == _vehicleName)
                                          _typeAheadControllerLicensePlate
                                              .text = vehicles[i].licensePlate;
                                      }
                                    });
                                  }
                                }
                              : null,
                          items: _dropdownMenuItemList.length > 0
                              ? _dropdownMenuItemList
                              : null,
                        ),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration:
                                  InputDecoration(labelText: 'Kennzeichen'),
                              keyboardType: TextInputType.text,
                              controller: _typeAheadControllerLicensePlate,
                              onChanged: (value) {
                                fieldsHaveChanged = true;
                              }),
                          noItemsFoundBuilder: (context) {
                            return SizedBox();
                          },
                          validator: (value) {
                            if (value != null && value.length > 12)
                              return 'Geben Sie maximal 12 Zeichen ein.';
                            return null;
                          },
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern, LifeSearch.licensePlates);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadControllerLicensePlate.text =
                                suggestion;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Zeit',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () async {
                            await _selectDate().then((value) {
                              if (value != null) {
                                _initialDate.text =
                                    DateFormat.yMMMd('de_DE').format(value);
                                dateTime = value;
                              }
                            });
                          },
                          child: IgnorePointer(
                            child: Stack(
                                alignment: AlignmentDirectional.centerEnd,
                                children: <Widget>[
                                  TextFormField(
                                      maxLines: 1,
                                      validator: (value) {
                                        if (value.isEmpty || value.length < 1) {
                                          return 'Wähle ein Datum.';
                                        }
                                        return null;
                                      },
                                      controller: _initialDate,
                                      decoration: InputDecoration(
                                        labelText: 'Datum',
                                        labelStyle: TextStyle(
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        fieldsHaveChanged = true;
                                      }),
                                  Icon(
                                    Icons.calendar_today,
                                    // color: Colors.black,
                                  ),
                                ]),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await _selectTime().then((value) {
                              if (value != null) {
                                _dayTime.text = value.hour.toString() +
                                    ':' +
                                    value.minute.toString();
                              }
                            });
                          },
                          child: IgnorePointer(
                            child: Stack(
                                alignment: AlignmentDirectional.centerEnd,
                                children: <Widget>[
                                  TextFormField(
                                    controller: _dayTime,
                                    decoration: InputDecoration(
                                      labelText: 'Tageszeit',
                                      labelStyle: TextStyle(
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      fieldsHaveChanged = true;
                                    },
                                  ),
                                  Icon(
                                    Icons.watch_later_outlined,
                                    // color: Colors.black,
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }

  Future<Null> _pickImage(bool mileageBegin) async {
    if (mileageBegin) {
      final pickedImage =
          await ImagePicker().getImage(source: ImageSource.camera);
      if (pickedImage != null) {
        final croppedImage = await _cropImage(pickedImage.path);
        if (croppedImage != null) {
          textRecognizer(croppedImage).then((value) {
            _mileageBegin.text =
                num.tryParse(value.text) == null ? "" : value.text;
            if (_mileageBegin.text.isNotEmpty &&
                num.tryParse(_mileageEnd.text) != null) {
              if (int.parse(_mileageEnd.text) >=
                  int.parse(_mileageBegin.text)) {
                setState(() {
                  var test = int.parse(_mileageEnd.text) -
                      int.parse(_mileageBegin.text);
                  _distance.text = test.toString();
                  fieldsHaveChanged = true;
                });
              } else {
                setState(() {
                  _distance.text = "";
                });
              }
            }
          });
        }
      }
    } else {
      final pickedImage =
          await ImagePicker().getImage(source: ImageSource.camera);
      if (pickedImage != null) {
        final croppedImage = await _cropImage(pickedImage.path);
        if (croppedImage != null) {
          textRecognizer(croppedImage).then((value) {
            if (num.tryParse(value.text) != null) {
              setState(() {
                _mileageEnd.text =
                    num.tryParse(value.text) == null ? "" : value.text;
                if (_mileageEnd.text.isNotEmpty &&
                    num.tryParse(_mileageBegin.text) != null) {
                  if (int.parse(_mileageEnd.text) >=
                      int.parse(_mileageBegin.text)) {
                    setState(() {
                      var test = int.parse(_mileageEnd.text) -
                          int.parse(_mileageBegin.text);
                      _distance.text = test.toString();
                      fieldsHaveChanged = true;
                    });
                  } else {
                    setState(() {
                      _distance.text = "";
                    });
                  }
                }
              });
            }
          });
        }
      }
    }
  }

  Future<VisionText> textRecognizer(File image) async {
    final data = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(data);
  }

  Future<File> _cropImage(String path) async {
    final croppedImage = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.ratio16x9]
            : [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Zuschneiden',
            toolbarColor: Theme.of(context).backgroundColor,
            statusBarColor: Theme.of(context).backgroundColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Theme.of(context).backgroundColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    return croppedImage;
  }
}
