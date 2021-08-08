import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/models/tour.dart';
import 'package:l17/models/vehicle.dart';

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
  var _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _typeAheadControllerVehicle =
      TextEditingController();
  bool _initializeTours = true;
  bool _initializeVehicles = true;
  String _selectedDriver;
  List<Vehicle> _vehicles = [];
  String _licensePlate = "";
  Map _lastMileageMap = Map();
  StreamSubscription<QuerySnapshot> _vehicleListener;
  StreamSubscription<QuerySnapshot> _licensePlateListener;
  List<String> _possibleCarNames = [];
  List<DropdownMenuItem<String>> _dropdownMenuItemList = [];

  @override
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    if (_selectedDriver != null && _initializeTours) {
      // fetches all of the used cars and store them in a list _possibleCarNames
      // _possibleCarNames contains only unique names
      _licensePlateListener = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((event) {
        var toursDocs = event.docs;
        _possibleCarNames = [];
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            if (toursDocs[i]['carName'] != "") {
              _possibleCarNames.add(toursDocs[i]['carName']);
            }
          }
          _possibleCarNames = _possibleCarNames.toSet().toList();
        }

        if (_initializeVehicles) {
          // creates an map containg all vehicles and their last mileage
          _vehicleListener = FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser.uid)
              .collection('vehicles')
              .snapshots()
              .listen((event) {
            _vehicles = [];
            var toursDocs = event.docs;
            _dropdownMenuItemList = [];
            _lastMileageMap = Map();
            _typeAheadControllerVehicle.text = "";
            _licensePlate = "";
            if (toursDocs.isNotEmpty) {
              for (int i = 0; i < toursDocs.length; i++) {
                _vehicles.add(Vehicle(toursDocs[i]['name'],
                    toursDocs[i]['licensePlate'], toursDocs[i].id));
                _lastMileageMap[toursDocs[i]['name']] =
                    toursDocs[i]['lastMileage'];
              }

              // creates a dropdownlist containing all existing vehicles
              _dropdownMenuItemList =
                  _vehicles.map<DropdownMenuItem<String>>((Vehicle vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle.name,
                  child: SizedBox(
                    child: Text(
                      vehicle.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList();

              // prepare the controllers, which represent the selected car and
              // their last mileage
              for (int i = 0; i < _possibleCarNames.length; i++) {
                if (_lastMileageMap[_possibleCarNames[i]] != null) {
                  _typeAheadControllerVehicle.text = _possibleCarNames[i];
                  _textFieldController.text =
                      _lastMileageMap[_possibleCarNames[i]] == 0
                          ? ""
                          : _lastMileageMap[_possibleCarNames[i]].toString();
                  for (int j = 0; j < _vehicles.length; j++) {
                    if (_vehicles[j].name == _possibleCarNames[i]) {
                      _licensePlate = _vehicles[j].licensePlate;
                      j = _vehicles.length;
                    }
                  }
                  i = _possibleCarNames.length;
                }
              }

              if (_typeAheadControllerVehicle.text == null ||
                  _typeAheadControllerVehicle.text.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _typeAheadControllerVehicle.text = _vehicles[0].name;
                  _textFieldController.text =
                      _lastMileageMap[_vehicles[0].name] == 0
                          ? ""
                          : _lastMileageMap[_vehicles[0].name].toString();

                  _licensePlate = _vehicles[0].licensePlate;
                });
              }
              if (mounted) setState(() {});
            }
            _initializeVehicles = false;
          });
        }
        _initializeTours = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_vehicleListener != null) _vehicleListener.cancel();
    if (_licensePlateListener != null) _licensePlateListener.cancel();
    _textFieldController.dispose();
    _typeAheadControllerVehicle.dispose();
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
        if (_dropdownMenuItemList.length > 0)
          _displayTextInputDialog(context);
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fügen Sie vorerst ein neues Fahrzeug im Side-Menü hinzu.',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                      DropdownButton<String>(
                        iconDisabledColor: Colors.grey.shade200,
                        underline: Container(),
                        disabledHint: SizedBox(
                          child: Text(
                            _typeAheadControllerVehicle.text,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        value: _typeAheadControllerVehicle.text,
                        onChanged: _dropdownMenuItemList.length > 0
                            ? (String value) {
                                if (value != null) {
                                  setState(() {
                                    _typeAheadControllerVehicle.text = value;
                                    _textFieldController.text =
                                        _lastMileageMap[value] == 0
                                            ? ""
                                            : _lastMileageMap[value].toString();
                                    _licensePlate = "";
                                    for (int i = 0; i < _vehicles.length; i++) {
                                      if (_vehicles[i].name == value)
                                        _licensePlate =
                                            _vehicles[i].licensePlate;
                                    }
                                  });
                                }
                              }
                            : null,
                        items: _dropdownMenuItemList.length > 0
                            ? _dropdownMenuItemList
                            : null,
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
                  Navigator.of(context).pushNamed(TourScreen.routeName,
                      arguments: Tour(
                          timestamp: daytime,
                          mileageBegin:
                              num.tryParse(_textFieldController.text) == null
                                  ? 0
                                  : int.parse(_textFieldController.text),
                          mileageEnd: 0,
                          attendant: "",
                          distance: 0,
                          licensePlate: _licensePlate,
                          tourBegin: "",
                          tourEnd: "",
                          roadCondition: "",
                          daytime: DateFormat.Hm('de_DE').format(daytime),
                          weather: "",
                          carName: _typeAheadControllerVehicle.text,
                          id: ""));
                },
              )
            ],
          );
        });
  }

  // triggers the smartphone camera
  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);
      if (croppedImage != null) {
        _textRecognizer(croppedImage).then((value) {
          _textFieldController.text =
              num.tryParse(value.text) == null ? "" : value.text;
        });
      }
    }
  }

  // processes the image and gives the result
  Future<VisionText> _textRecognizer(File image) async {
    final data = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(data);
  }

  // crops a given image from file path
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
    );
    return croppedImage;
  }
}
