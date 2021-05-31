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
  final TextEditingController _typeAheadControllerVehicle =
      TextEditingController();
  bool initTours = true;
  bool initVehicles = true;
  String _selectedDriver;
  List<Vehicle> vehicles = [];
  String licensePlate = "";
  Map lastMileageMap = Map();
  StreamSubscription<QuerySnapshot> vehicleListener;
  StreamSubscription<QuerySnapshot> licensePlateListener;
  List<String> possibleCarNames = [];
  List<DropdownMenuItem<String>> dropdownMenuItemList = [];

  @override
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    if (_selectedDriver != null && initTours) {
      licensePlateListener = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((event) {
        var toursDocs = event.docs;
        possibleCarNames = [];
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            if (toursDocs[i]['carName'] != "") {
              possibleCarNames.add(toursDocs[i]['carName']);
            }
          }
          possibleCarNames = possibleCarNames.toSet().toList();
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
            dropdownMenuItemList = [];
            lastMileageMap = Map();
            _typeAheadControllerVehicle.text = "";
            licensePlate = "";
            if (toursDocs.isNotEmpty) {
              for (int i = 0; i < toursDocs.length; i++) {
                vehicles.add(Vehicle(toursDocs[i]['name'],
                    toursDocs[i]['licensePlate'], toursDocs[i].id));
                lastMileageMap[toursDocs[i]['name']] =
                    toursDocs[i]['lastMileage'];
              }
              dropdownMenuItemList =
                  vehicles.map<DropdownMenuItem<String>>((Vehicle vehicle) {
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
              for (int i = 0; i < possibleCarNames.length; i++) {
                if (lastMileageMap[possibleCarNames[i]] != null) {
                  _typeAheadControllerVehicle.text = possibleCarNames[i];
                  _textFieldController.text =
                      lastMileageMap[possibleCarNames[i]] == 0
                          ? ""
                          : lastMileageMap[possibleCarNames[i]].toString();
                  for (int j = 0; j < vehicles.length; j++) {
                    if (vehicles[j].name == possibleCarNames[i]) {
                      licensePlate = vehicles[j].licensePlate;
                      j = vehicles.length;
                    }
                  }
                  i = possibleCarNames.length;
                }
              }
              if (_typeAheadControllerVehicle.text == null ||
                  _typeAheadControllerVehicle.text.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _typeAheadControllerVehicle.text = vehicles[0].name;
                  _textFieldController.text =
                      lastMileageMap[vehicles[0].name] == 0
                          ? ""
                          : lastMileageMap[vehicles[0].name].toString();

                  licensePlate = vehicles[0].licensePlate;
                });
              }
              if (mounted) setState(() {});
            }
            initVehicles = false;
          });
        }
        initTours = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (vehicleListener != null) vehicleListener.cancel();
    if (licensePlateListener != null) licensePlateListener.cancel();
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
        if (dropdownMenuItemList.length > 0)
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
                          // width: width * 0.75,
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
                        onChanged: dropdownMenuItemList.length > 0
                            ? (String value) {
                                if (value != null) {
                                  setState(() {
                                    _typeAheadControllerVehicle.text = value;
                                    _textFieldController.text =
                                        lastMileageMap[value] == 0
                                            ? ""
                                            : lastMileageMap[value].toString();
                                    licensePlate = "";
                                    for (int i = 0; i < vehicles.length; i++) {
                                      if (vehicles[i].name == value)
                                        licensePlate = vehicles[i].licensePlate;
                                    }
                                  });
                                }
                              }
                            : null,
                        items: dropdownMenuItemList.length > 0
                            ? dropdownMenuItemList
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
                            licensePlate: licensePlate,
                            tourBegin: "",
                            tourEnd: "",
                            roadCondition: "",
                            daytime: DateFormat.Hm('de_DE').format(daytime),
                            weather: "",
                            carName: _typeAheadControllerVehicle.text),
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
          _textFieldController.text =
              num.tryParse(value.text) == null ? "" : value.text;
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
}
