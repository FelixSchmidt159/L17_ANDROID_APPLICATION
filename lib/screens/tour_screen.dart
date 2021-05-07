import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';
import 'package:l17/providers/tour.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  String _test = "trocken";
  List<String> _licensePlates = [];
  List<String> _attendants = [];
  List<String> _locations = [];

  var _editedProduct = Tour(
    timestamp: DateTime.now(),
    distance: 0,
    mileageBegin: 0,
    mileageEnd: 0,
    licensePlate: "",
    tourBegin: "",
    tourEnd: "",
    roadCondition: "",
    attendant: "",
  );
  var _initValues = {
    'id': "",
    'timestamp': DateTime.now(),
    'distance': "",
    'mileageBegin': "",
    'mileageEnd': "",
    'licensePlate': "",
    'tourBegin': "",
    'tourEnd': "",
    'roadCondition': "",
    'attendant': "",
  };

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('/users/' + currentUser.uid + '/tours')
        .where('licensePlate')
        .snapshots()
        .listen(
      (event) {
        final toursDocs = event.docs;
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            _licensePlates.add(toursDocs[i]['licensePlate']);
            _attendants.add(toursDocs[i]['attendant']);
            _locations.add(toursDocs[i]['tourBegin']);
            _locations.add(toursDocs[i]['tourEnd']);
          }
          _licensePlates = _licensePlates.toSet().toList();
          _locations = _locations.toSet().toList();
          _attendants = _attendants.toSet().toList();
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _typeAheadControllerLicensePlate.dispose();
    _typeAheadControllerTourBegin.dispose();
    _typeAheadControllerTourEnd.dispose();
    _typeAheadControllerAttendant.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    tourObject =
        ModalRoute.of(context).settings.arguments as TourScreenArguments;
    if (tourObject != null) {
      _initValues = {
        'timestamp': tourObject.tour.timestamp,
        'distance': tourObject.tour.distance,
        'mileageBegin': tourObject.tour.mileageBegin,
        'mileageEnd': tourObject.tour.mileageEnd,
        'licensePlate': tourObject.tour.licensePlate,
        'tourBegin': tourObject.tour.tourBegin,
        'tourEnd': tourObject.tour.tourEnd,
        'roadCondition': tourObject.tour.roadCondition,
        'attendant': tourObject.tour.attendant
      };
      _test = tourObject.tour.roadCondition == ""
          ? "trocken"
          : tourObject.tour.roadCondition;
      _typeAheadControllerLicensePlate.text = tourObject.tour.licensePlate;
      _typeAheadControllerTourBegin.text = tourObject.tour.tourBegin;
      _typeAheadControllerTourEnd.text = tourObject.tour.tourEnd;
      _typeAheadControllerAttendant.text = tourObject.tour.attendant;
    }
    super.didChangeDependencies();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (tourObject.id == "") {
      FirebaseFirestore.instance
          .collection('/users/' + currentUser.uid + '/tours')
          .add({
        'timestamp': _editedProduct.timestamp,
        'distance': _editedProduct.distance,
        'mileageBegin': _editedProduct.mileageBegin,
        'mileageEnd': _editedProduct.mileageEnd,
        'licensePlate': _editedProduct.licensePlate,
        'tourBegin': _editedProduct.tourBegin,
        'tourEnd': _editedProduct.tourEnd,
        'roadCondition': _editedProduct.roadCondition,
        'attendant': _editedProduct.attendant
      });
    } else {
      FirebaseFirestore.instance
          .collection('/users/' + currentUser.uid + '/tours')
          .doc(tourObject.id)
          .update({
        'timestamp': _editedProduct.timestamp,
        'distance': _editedProduct.distance,
        'mileageBegin': _editedProduct.mileageBegin,
        'mileageEnd': _editedProduct.mileageEnd,
        'licensePlate': _editedProduct.licensePlate,
        'tourBegin': _editedProduct.tourBegin,
        'tourEnd': _editedProduct.tourEnd,
        'roadCondition': _editedProduct.roadCondition,
        'attendant': _editedProduct.attendant
      });
    }
    Navigator.of(context).pop();
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
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tour'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue:
                    DateFormat.yMMMd('de_DE').format(_initValues['timestamp']),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
                decoration: InputDecoration(labelText: 'Datum'),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                initialValue: _initValues['distance'] == 0
                    ? ""
                    : _initValues['distance'].toString(),
                decoration: InputDecoration(labelText: 'Distanz'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isNotEmpty && num.tryParse(value) == null) {
                    return 'Geben Sie bitte eine ganze Zahl ein.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: value.isEmpty ? 0 : int.parse(value),
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['mileageBegin'] == 0
                    ? ""
                    : _initValues['mileageBegin'].toString(),
                decoration:
                    InputDecoration(labelText: 'Kilometerstand (Beginn)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isNotEmpty && num.tryParse(value) == null) {
                    return 'Geben Sie bitte eine ganze Zahl ein.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: value.isEmpty ? 0 : int.parse(value),
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['mileageEnd'] == 0
                    ? ""
                    : _initValues['mileageEnd'].toString(),
                decoration: InputDecoration(labelText: 'Kilometerstand (Ziel)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isNotEmpty && num.tryParse(value) == null) {
                    return 'Geben Sie bitte eine ganze Zahl ein.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: value.isEmpty ? 0 : int.parse(value),
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(labelText: 'Kennzeichen'),
                  keyboardType: TextInputType.text,
                  controller: _typeAheadControllerLicensePlate,
                ),
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: value,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
                suggestionsCallback: (pattern) {
                  return getSuggestions(pattern, LifeSearch.licensePlates);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadControllerLicensePlate.text = suggestion;
                },
              ),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(labelText: 'Startort'),
                  keyboardType: TextInputType.text,
                  controller: _typeAheadControllerTourBegin,
                ),
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: value,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
                suggestionsCallback: (pattern) {
                  return getSuggestions(pattern, LifeSearch.locations);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadControllerTourBegin.text = suggestion;
                },
              ),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(labelText: 'Zielort'),
                  keyboardType: TextInputType.text,
                  controller: _typeAheadControllerTourEnd,
                ),
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: value,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
                suggestionsCallback: (pattern) {
                  return getSuggestions(pattern, LifeSearch.locations);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadControllerTourEnd.text = suggestion;
                },
              ),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(labelText: 'Begleiter'),
                  controller: _typeAheadControllerAttendant,
                ),
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: value);
                },
                suggestionsCallback: (pattern) {
                  return getSuggestions(pattern, LifeSearch.attendants);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadControllerAttendant.text = suggestion;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Straßenzustand'),
                items: ['nass', 'trocken', 'eisig', 'schneebedeckt']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _test = value;
                  });
                },
                value: _test,
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: _editedProduct.timestamp,
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: value,
                      attendant: _editedProduct.attendant);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
