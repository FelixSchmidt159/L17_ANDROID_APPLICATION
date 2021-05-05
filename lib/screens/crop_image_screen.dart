import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:l17/models/TourScreenArguments.dart';

import 'package:l17/providers/tour.dart';
import 'package:l17/screens/tour_screen.dart';

class CropImageScreen extends StatefulWidget {
  static const routeName = '/crop-image-screen';
  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

enum AppState {
  // free,
  picked,
  cropped,
}

class _CropImageScreenState extends State<CropImageScreen> {
  AppState state;
  File imageFile;
  File croppedFile;
  bool mounted = true;

  @override
  void initState() {
    super.initState();
    state = AppState.cropped;
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      imageFile = ModalRoute.of(context).settings.arguments as File;
      _cropImage();
      mounted = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kilometerstand korrigieren'),
      ),
      body: Center(
        child: croppedFile != null
            ? Image.file(croppedFile)
            : Image.file(imageFile),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // if (state == AppState.free)
          //   _pickImage();
          if (state == AppState.picked)
            _cropImage();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    // if (state == AppState.free)
    //   return Icon(Icons.camera_alt_rounded);
    if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.check);
    else
      return Container();
  }

  // Future<Null> _pickImage() async {
  //   final pickedImage =
  //       await ImagePicker().getImage(source: ImageSource.gallery);
  //   imageFile = pickedImage != null ? File(pickedImage.path) : null;
  //   if (imageFile != null) {
  //     setState(() {
  //       state = AppState.picked;
  //     });
  //   }
  // }

  Future<Null> _cropImage() async {
    croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.ratio16x9]
            : [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Zuschneiden',
            toolbarColor: Colors.green,
            statusBarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.green,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      // imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  Future<VisionText> textRecognizer(File image) async {
    final data = FirebaseVisionImage.fromFile(image);
    // final visionImage = FirebaseVisionImage.fromBytes(bytes, metadata);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(data);
  }

  void _clearImage() {
    textRecognizer(croppedFile).then((value) {
      Navigator.of(context).pop(context);
      Navigator.of(context).pushNamed(
        TourScreen.routeName,
        arguments: TourScreenArguments(
            Tour(
                timestamp: DateTime.now(),
                mileageBegin: num.tryParse(value.text) == null
                    ? 0
                    : int.parse(value.text),
                mileageEnd: 0,
                attendant: "",
                distance: 0,
                licensePlate: "",
                tourBegin: "",
                tourEnd: "",
                roadCondition: ""),
            ""),
      );
    });
  }
}
