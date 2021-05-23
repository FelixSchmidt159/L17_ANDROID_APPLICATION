import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';

import 'package:l17/screens/tour_screen.dart';
import 'package:l17/widgets/create_pdf.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/tour_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant/instant.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _selectedIndex = 1;
  var currentUser = FirebaseAuth.instance.currentUser;
  int lastMileageEnd;
  TextEditingController _textFieldController = TextEditingController();
  String _selectedDriver;
  Stream<QuerySnapshot> reference;
  StreamSubscription<QuerySnapshot> streamRef;

  @override
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    lastMileageEnd = 0;
    if (_selectedDriver != null) {
      reference = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .snapshots();
      streamRef = reference.listen((event) {
        final toursDocs = event.docs;
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < 1; i++) {
            lastMileageEnd = toursDocs[i]['mileageEnd'];
            _textFieldController.text = toursDocs[i]['mileageEnd'].toString();
          }
          if (lastMileageEnd == 0) {
            _textFieldController.text = "";
          }
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (streamRef != null) {
      streamRef.cancel();
    }
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Fahrtenbuch'),
      centerTitle: true,
      actions: [
        DropdownButton(
          underline: Container(),
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          items: [
            DropdownMenuItem(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Logout'),
                  ],
                ),
              ),
              value: 'logout',
            )
          ],
          onChanged: (itemIdentifier) {
            if (itemIdentifier == 'logout') {
              FirebaseAuth.instance.signOut();
            }
          },
        )
      ],
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
      selectedItemColor: Colors.black,
      backgroundColor: Theme.of(context).backgroundColor,
      unselectedItemColor: Colors.white,
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
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Fahrt hinzufügen'),
            content: Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    if (num.tryParse(value) != null)
                      lastMileageEnd = int.parse(value);
                    else
                      lastMileageEnd = 0;
                  },
                  controller: _textFieldController,
                  decoration:
                      InputDecoration(hintText: "Kilometerstand (Beginn)"),
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
                  setState(() {
                    var daytime =
                        dateTimeToOffset(offset: 2.0, datetime: DateTime.now());
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(
                      TourScreen.routeName,
                      arguments: TourScreenArguments(
                          Tour(
                              timestamp: daytime,
                              mileageBegin: lastMileageEnd,
                              mileageEnd: 0,
                              attendant: "",
                              distance: 0,
                              licensePlate: "",
                              tourBegin: "",
                              tourEnd: "",
                              roadCondition: "",
                              daytime: DateFormat.Hm('de_DE').format(daytime)),
                          ""),
                    );
                  });
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
                    licensePlate: "",
                    tourBegin: "",
                    tourEnd: "",
                    roadCondition: "",
                    daytime: DateFormat.Hm('de_DE').format(
                      daytime,
                    )),
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
}
