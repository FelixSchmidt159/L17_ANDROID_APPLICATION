import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l17/providers/tour.dart';

class TourScreen extends StatefulWidget {
  static const routeName = '/tour-screen';

  @override
  _TourScreenState createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

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
  );
  var _initValues = {
    'timestamp': DateTime.now(),
    'distance': 0,
    'mileageBegin': 0,
    'mileageEnd': 0,
    'licensePlate': "",
    'tourBegin': "",
    'tourEnd': "",
    'roadCondition': "",
    'attendant': "",
  };
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final tour = ModalRoute.of(context).settings.arguments as Tour;
      if (tour != null) {
        _initValues = {
          'timestamp': tour.timestamp,
          'distance': tour.distance,
          'mileageBegin': tour.mileageBegin,
          'mileageEnd': tour.mileageEnd,
          'licensePlate': tour.licensePlate,
          'tourBegin': tour.tourBegin,
          'tourEnd': tour.tourEnd,
          'roadCondition': tour.roadCondition,
          'attendant': tour.attendant
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    // if (_editedProduct.id != null) {
    //   Provider.of<Products>(context, listen: false)
    //       .updateProduct(_editedProduct.id, _editedProduct);
    // } else {
    //   Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    // }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              TextFormField(
                initialValue:
                    DateFormat.yMMMd('de_DE').format(_initValues['timestamp']),
                decoration: InputDecoration(labelText: 'Datum'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.datetime,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['distance'].toString(),
                decoration: InputDecoration(labelText: 'Distanz'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: int.parse(value),
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['mileageBegin'].toString(),
                decoration:
                    InputDecoration(labelText: 'Kilometerstand (Beginn)'),
                keyboardType: TextInputType.number,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: int.parse(value),
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['mileageEnd'].toString(),
                decoration: InputDecoration(labelText: 'Kilometerstand (Ziel)'),
                keyboardType: TextInputType.number,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: int.parse(value),
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['licensePlate'],
                decoration: InputDecoration(labelText: 'Kennzeichen'),
                keyboardType: TextInputType.text,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: value,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['tourBegin'],
                decoration: InputDecoration(labelText: 'Startort'),
                keyboardType: TextInputType.text,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: value,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['tourEnd'],
                decoration: InputDecoration(labelText: 'Zielort'),
                keyboardType: TextInputType.text,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: _editedProduct.licensePlate,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: value,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['roadCondition'],
                decoration:
                    InputDecoration(labelText: 'Straßenzustand/Witterung'),
                keyboardType: TextInputType.text,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: value,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
              TextFormField(
                initialValue: _initValues['attendant'],
                decoration: InputDecoration(labelText: 'Begleiter'),
                keyboardType: TextInputType.text,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      timestamp: DateTime.now(),
                      distance: _editedProduct.distance,
                      mileageBegin: _editedProduct.mileageBegin,
                      mileageEnd: _editedProduct.mileageEnd,
                      licensePlate: value,
                      tourBegin: _editedProduct.tourBegin,
                      tourEnd: _editedProduct.tourEnd,
                      roadCondition: _editedProduct.roadCondition,
                      attendant: _editedProduct.attendant);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
