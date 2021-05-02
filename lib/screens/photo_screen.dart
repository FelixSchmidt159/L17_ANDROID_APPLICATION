import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:l17/models/PhotoScreenArguments.dart';

class PhotoScreen extends StatefulWidget {
  static const routeName = '/photo-screen';
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  Widget build(BuildContext context) {
    final photoScreenArguments =
        ModalRoute.of(context).settings.arguments as PhotoScreenArguments;
    final appBar = AppBar(
      title: const Text('Tour'),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                width: 150,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: photoScreenArguments.image != null
                    ? Image.file(
                        photoScreenArguments.image,
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
          Text(photoScreenArguments.result),
        ],
      ),
    );
  }
}
