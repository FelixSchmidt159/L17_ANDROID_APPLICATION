import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class PhotoScreen extends StatefulWidget {
  static const routeName = '/photo-screen';
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  Future<VisionText> textRecognizer(File image) async {
    final data = FirebaseVisionImage.fromFile(image);
    // final visionImage = FirebaseVisionImage.fromBytes(bytes, metadata);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(data);
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseFirestore.instance
    //     .collection('/chats/uQqmW3UnKAA8k3QfZnkD/messages')
    //     .doc('5WEFcgbfzgSBZiCC06MR')
    //     .update({'test': 'MOIII'});
    // FirebaseFirestore.instance
    //     .collection('chats/jp0eMfsXmtBrfJTH6cfp/messages')
    //     .snapshots()
    //     .listen((event) {
    //   print('////////////////////////////////');
    //   print(event.docs[0]['text']);
    //   print('////////////////////////////////');
    // });
    final image = ModalRoute.of(context).settings.arguments as File;

    String result = "";

    textRecognizer(image).then((value) {
      String text = value.text;
      for (TextBlock block in value.blocks) {
        final Rect boundingBox = block.boundingBox;
        final List<Offset> cornerPoints = block.cornerPoints;
        final String text = block.text;
        final List<RecognizedLanguage> languages = block.recognizedLanguages;
        result += "\n";
        for (TextLine line in block.lines) {
          // Same getters as TextBlock
          for (TextElement element in line.elements) {
            // Same getters as TextBlockresult
            result += element.text;
          }
        }
        result += "\n";
      }
      print("--------------------------------");
      print(result);
      print("--------------------------------");
    });

    final appBar = AppBar(
      title: const Text('Tour'),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: <Widget>[
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: image != null
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Text(
                    'No Image Taken',
                    textAlign: TextAlign.center,
                  ),
            alignment: Alignment.center,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
