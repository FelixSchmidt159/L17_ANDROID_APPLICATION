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
  TextEditingController _distance = TextEditingController();
  List<String> _licensePlates = [];
  List<String> _attendants = [];
  List<String> _locations = [];
  String suggestedLicensePlate = "";
  String suggestedAttendant = "";
  String suggestedRoadCondition = "trocken";
  bool _initialize = true;
  String _selectedDriver;
  Stream<QuerySnapshot> reference;
  StreamSubscription<QuerySnapshot> streamRef;

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
    daytime: "",
  );

  @override
  void dispose() {
    _typeAheadControllerLicensePlate.dispose();
    _typeAheadControllerTourBegin.dispose();
    _typeAheadControllerTourEnd.dispose();
    _typeAheadControllerAttendant.dispose();
    _initialDate.dispose();
    _mileageBegin.dispose();
    _mileageEnd.dispose();
    _distance.dispose();
    if (streamRef != null) {
      streamRef.cancel();
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
      tourObject =
          ModalRoute.of(context).settings.arguments as TourScreenArguments;
    }

    if (_initialize) {
      suggestedRoadCondition = tourObject.tour.roadCondition == ""
          ? "trocken"
          : tourObject.tour.roadCondition;
      _typeAheadControllerTourBegin.text = tourObject.tour.tourBegin;
      _typeAheadControllerTourEnd.text = tourObject.tour.tourEnd;
      _typeAheadControllerLicensePlate.text = tourObject.tour.licensePlate;
      _typeAheadControllerAttendant.text = tourObject.tour.attendant;
      _editedProduct.timestamp = tourObject.tour.timestamp;
      _initialDate.text =
          DateFormat.yMMMd('de_DE').format(tourObject.tour.timestamp);
      _mileageEnd.text = tourObject.tour.mileageEnd == 0
          ? ""
          : tourObject.tour.mileageEnd.toString();
      _mileageBegin.text = tourObject.tour.mileageBegin == 0
          ? ""
          : tourObject.tour.mileageBegin.toString();
    }

    if (_selectedDriver != null) {
      reference = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .snapshots();
      streamRef = reference.listen(
        (event) {
          final toursDocs = event.docs;
          if (toursDocs.isNotEmpty && _initialize) {
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
            _licensePlates = _licensePlates.toSet().toList();
            _locations = _locations.toSet().toList();
            _attendants = _attendants.toSet().toList();

            if (tourObject.id == "") {
              if (mounted) {
                setState(() {
                  _typeAheadControllerLicensePlate.text = suggestedLicensePlate;
                  _typeAheadControllerAttendant.text = suggestedAttendant;
                });
              }
            }
            _initialize = false;
          }
        },
      );
    }

    super.didChangeDependencies();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_selectedDriver != null) {
      if (tourObject.id == "") {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('tours')
            .add({
          'timestamp': _editedProduct.timestamp,
          'distance': _editedProduct.distance,
          'mileageBegin': _editedProduct.mileageBegin,
          'mileageEnd': _editedProduct.mileageEnd,
          'licensePlate': _editedProduct.licensePlate,
          'tourBegin': _editedProduct.tourBegin,
          'tourEnd': _editedProduct.tourEnd,
          'roadCondition': _editedProduct.roadCondition,
          'attendant': _editedProduct.attendant,
          'daytime': _editedProduct.daytime,
        });
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('tours')
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
          'attendant': _editedProduct.attendant,
          'daytime': _editedProduct.daytime,
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fügen Sie vorerst einen neuen Fahrer hinzu.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
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

  Future<DateTime> _selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: _editedProduct.timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  Future<bool> _onWillPop() async {
    if (true) return true;
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            // backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Die Änderungen wurden nicht gespeichert.',
            ),
            content: Text('Wollen Sie die Änderungen verwerfen?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.green, primary: Colors.white),
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Ja'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red, primary: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Nein'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
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
                          attendant: _editedProduct.attendant,
                          daytime: _editedProduct.daytime);
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
                  Stack(alignment: AlignmentDirectional.centerEnd, children: <
                      Widget>[
                    TextFormField(
                      controller: _mileageBegin,
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
                            attendant: _editedProduct.attendant,
                            daytime: _editedProduct.daytime);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        // color: Colors.black,
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        _pickImage(true);
                      },
                    ),
                  ]),
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
                          attendant: _editedProduct.attendant,
                          daytime: _editedProduct.daytime);
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
                  Stack(alignment: AlignmentDirectional.centerEnd, children: <
                      Widget>[
                    TextFormField(
                      controller: _mileageEnd,
                      decoration:
                          InputDecoration(labelText: 'Kilometerstand (Ziel)'),
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
                            attendant: _editedProduct.attendant,
                            daytime: _editedProduct.daytime);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        // color: Colors.black,
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        _pickImage(false);
                      },
                    ),
                  ]),
                  TextFormField(
                    initialValue: tourObject.tour.distance == 0
                        ? ""
                        : tourObject.tour.distance.toString(),
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
                          attendant: _editedProduct.attendant,
                          daytime: _editedProduct.daytime);
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
                          attendant: _editedProduct.attendant,
                          daytime: _editedProduct.daytime);
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
                  InkWell(
                    onTap: () async {
                      await _selectDate().then((value) {
                        if (value != null) {
                          _initialDate.text =
                              DateFormat.yMMMd('de_DE').format(value);
                          _editedProduct = Tour(
                              timestamp: value,
                              distance: _editedProduct.distance,
                              mileageBegin: _editedProduct.mileageBegin,
                              mileageEnd: _editedProduct.mileageEnd,
                              licensePlate: _editedProduct.licensePlate,
                              tourBegin: _editedProduct.tourBegin,
                              tourEnd: _editedProduct.tourEnd,
                              roadCondition: _editedProduct.roadCondition,
                              attendant: _editedProduct.attendant,
                              daytime: _editedProduct.daytime);
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
                                  decorationStyle: TextDecorationStyle.solid,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                // color: Colors.black,
                              ),
                              onPressed: () {
                                // Navigator.pop(context);
                                _pickImage(true);
                              },
                            )
                          ]),
                    ),
                  ),
                  TextFormField(
                    initialValue: tourObject.tour.daytime,
                    validator: (value) {
                      if (value.contains(
                              RegExp(r'(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]')) &&
                          value.length == 5) return null;
                      return "Bitte geben Sie eine Uhrzeit im Format hh:mm an.";
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
                          attendant: _editedProduct.attendant,
                          daytime: value);
                    },
                    decoration: InputDecoration(labelText: 'Tageszeit'),
                    keyboardType: TextInputType.number,
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
                          attendant: value,
                          daytime: _editedProduct.daytime);
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
                        suggestedRoadCondition = value;
                      });
                    },
                    value: suggestedRoadCondition,
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
                          attendant: _editedProduct.attendant,
                          daytime: _editedProduct.daytime);
                    },
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
            setState(() {
              _mileageBegin.text = value.text;
            });
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
                _mileageEnd.text = value.text;
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
