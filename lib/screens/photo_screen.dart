import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoScreen extends StatefulWidget {
  static const routeName = '/photo-screen';
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  Widget build(BuildContext context) {
    final _storedImage = ModalRoute.of(context).settings.arguments as File;
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
            child: _storedImage != null
                ? Image.file(
                    _storedImage,
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
