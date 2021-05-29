import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';
import 'package:l17/providers/vehicle.dart';

import 'package:l17/screens/tour_screen.dart';
import 'package:l17/widgets/create_pdf.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/tour_list.dart';
import 'package:image_picker/image_picker.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _selectedIndex = 1;
  var currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _typeAheadControllerLicensePlate =
      TextEditingController();
  bool initTours = true;
  bool initVehicles = true;
  String _selectedDriver;
  List<Vehicle> vehicles = [];
  List<String> _licensePlates = [];
  Map lastMileageMap = Map();
  StreamSubscription<QuerySnapshot> vehicleListener;

  @override
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    if (_selectedDriver != null && initTours) {
      _licensePlates = [];
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .orderBy('timestamp', descending: true)
          .get()
          .then((value) {
        var toursDocs = value.docs;
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            if (toursDocs[i]['licensePlate'] != "") {
              _licensePlates.add(toursDocs[i]['licensePlate']);
              if (lastMileageMap[toursDocs[i]['licensePlate']] == null) {
                lastMileageMap[toursDocs[i]['licensePlate']] =
                    toursDocs[i]['mileageEnd'];
              }
            }
            if (i == 0) {
              if (toursDocs[i]['licensePlate'] != "") {
                var dist = lastMileageMap[toursDocs[i]['licensePlate']];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _textFieldController.text = dist.toString();
                  _typeAheadControllerLicensePlate.text =
                      toursDocs[i]['licensePlate'];
                });
              }
            }
          }
          if (mounted) setState(() {});
        }
        initTours = false;
      });
    }
    if (initVehicles) {
      vehicleListener = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('vehicles')
          .snapshots()
          .listen((event) {
        vehicles = [];
        var toursDocs = event.docs;
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            vehicles.add(Vehicle(toursDocs[i]['name'],
                toursDocs[i]['licensePlate'], toursDocs[i].id));
          }
          if (_typeAheadControllerLicensePlate.text == null ||
              _typeAheadControllerLicensePlate.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _typeAheadControllerLicensePlate.text = vehicles[0].licensePlate;
            });
          }
          if (mounted) setState(() {});
        }
        initVehicles = false;
      });
    }

    if (_typeAheadControllerLicensePlate.text.isNotEmpty) {
      if (lastMileageMap[_typeAheadControllerLicensePlate.text] != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textFieldController.text =
              lastMileageMap[_typeAheadControllerLicensePlate.text].toString();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textFieldController.text = '';
        });
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (vehicleListener != null) vehicleListener.cancel();
    _textFieldController.dispose();
    _typeAheadControllerLicensePlate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Fahrtenbuch'),
      centerTitle: true,
    );
    final bottomBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.picture_as_pdf),
          label: 'PDF erzeugen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Fahrtenbuch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_road),
          label: 'Fahrt hinzufügen',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      backgroundColor: Theme.of(context).backgroundColor,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    );
    var height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).viewInsets.bottom;
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      height -= kBottomNavigationBarHeight;
    }

    final width = MediaQuery.of(context).size.width;

    List<Widget> _widgetOptions = <Widget>[
      CreatePdf(height, width),
      TourList(height, width),
    ];

    return Scaffold(
      appBar: appBar,
      body: _widgetOptions.elementAt(_selectedIndex),
      drawer: AppDrawer(),
      bottomNavigationBar: bottomBar,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index != 2)
        _selectedIndex = index;
      else {
        _displayTextInputDialog(context);
      }
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    var height = MediaQuery.of(context).size.height;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Fahrt hinzufügen'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: height * 0.20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TypeAheadFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: InputDecoration(labelText: 'Kennzeichen'),
                          keyboardType: TextInputType.text,
                          controller: _typeAheadControllerLicensePlate,
                        ),
                        noItemsFoundBuilder: (context) {
                          return SizedBox();
                        },
                        suggestionsCallback: (pattern) {
                          return getSuggestions(pattern);
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
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          TextField(
                            controller: _textFieldController,
                            decoration: InputDecoration(
                              labelText: "Kilometerstand (Beginn)",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImage();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red, primary: Colors.white),
                child: Text('Abbrechen'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.green, primary: Colors.white),
                child: Text('Weiter'),
                onPressed: () {
                  var daytime = DateTime.now();
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    TourScreen.routeName,
                    arguments: TourScreenArguments(
                        Tour(
                            timestamp: daytime,
                            mileageBegin:
                                num.tryParse(_textFieldController.text) == null
                                    ? 0
                                    : int.parse(_textFieldController.text),
                            mileageEnd: 0,
                            attendant: "",
                            distance: 0,
                            licensePlate: _typeAheadControllerLicensePlate.text,
                            tourBegin: "",
                            tourEnd: "",
                            roadCondition: "",
                            daytime: DateFormat.Hm('de_DE').format(daytime),
                            weather: ""),
                        ""),
                  );
                },
              ),
            ],
          );
        });
  }

  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);
      if (croppedImage != null) {
        textRecognizer(croppedImage).then((value) {
          var daytime = DateTime.now();
          Navigator.of(context).pushNamed(
            TourScreen.routeName,
            arguments: TourScreenArguments(
                Tour(
                    timestamp: daytime,
                    mileageBegin: num.tryParse(value.text) == null
                        ? 0
                        : int.parse(value.text),
                    mileageEnd: 0,
                    attendant: "",
                    distance: 0,
                    licensePlate: _typeAheadControllerLicensePlate.text,
                    tourBegin: "",
                    tourEnd: "",
                    roadCondition: "",
                    daytime: DateFormat.Hm('de_DE').format(
                      daytime,
                    ),
                    weather: ""),
                ""),
          );
        });
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

  List<String> getSuggestions(
    String pattern,
  ) {
    List<String> suggestions = [];
    List<String> possibleSuggestions = [];

    possibleSuggestions = _licensePlates;

    for (String str in possibleSuggestions) {
      if (str.toLowerCase().contains(pattern.toLowerCase())) {
        suggestions.add(str);
      }
    }

    for (int i = 0; i < vehicles.length; i++) {
      suggestions.add(vehicles[i].licensePlate);
    }

    suggestions = suggestions.toSet().toList();
    return suggestions;
  }
}
