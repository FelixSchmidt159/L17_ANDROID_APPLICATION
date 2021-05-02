import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:l17/models/PhotoScreenArguments.dart';
import 'package:l17/screens/photo_screen.dart';

class Test extends StatefulWidget {
  static const routeName = '/test';
  @override
  _TestState createState() => _TestState();
}

enum AppState {
  // free,
  picked,
  cropped,
}

class _TestState extends State<Test> {
  AppState state;
  File imageFile;
  File croppedFile;

  @override
  void initState() {
    super.initState();
    state = AppState.picked;
  }

  @override
  Widget build(BuildContext context) {
    imageFile = ModalRoute.of(context).settings.arguments as File;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kilometerstand zuschneiden'),
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
            ? [
                // CropAspectRatioPreset.square,
                // CropAspectRatioPreset.ratio3x2,
                // CropAspectRatioPreset.original,
                // CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                // CropAspectRatioPreset.original,
                // CropAspectRatioPreset.square,
                // CropAspectRatioPreset.ratio3x2,
                // CropAspectRatioPreset.ratio4x3,
                // CropAspectRatioPreset.ratio5x3,
                // CropAspectRatioPreset.ratio5x4,
                // CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
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
      Navigator.of(context).pushNamed(PhotoScreen.routeName,
          arguments: PhotoScreenArguments(croppedFile, value.text));
      print(value.text);
    });
  }
}
