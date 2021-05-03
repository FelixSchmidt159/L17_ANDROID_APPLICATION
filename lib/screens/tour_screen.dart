import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l17/providers/tour.dart';

class TourScreen extends StatefulWidget {
  static const routeName = '/tour-screen';

  @override
  _TourScreenState createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  // final _distanceFocusNode = FocusNode();
  // final _mileageBeginFocusNode = FocusNode();
  // final _mileageEndFocusNode = FocusNode();
  // final _licensePlateFocusNode = FocusNode();
  // final _tourBeginFocusNode = FocusNode();
  // final _tourEndFocusNode = FocusNode();
  // final _roadConditionFocusNode = FocusNode();
  // final _attendantFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  var _editedProduct = Tour(
    id: DateTime.now(),
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
    'id': DateTime.now(),
    'timestamp': DateTime.now(),
    'distance': "",
    'mileageBegin': "",
    'mileageEnd': "",
    'licensePlate': "",
    'tourBegin': "",
    'tourEnd': "",
    'roadCondition': "",
    'attendant': "",
  };
  var _isInit = true;

  @override
  void didChangeDependencies() {
    print('ayyyyyyyyyyyyyyyyyyyyy');
    if (_isInit) {
      final tour = ModalRoute.of(context).settings.arguments as Tour;
      if (tour != null) {
        _initValues = {
          'id': tour.id,
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
    // _distanceFocusNode.dispose();
    // _mileageBeginFocusNode.dispose();
    // _mileageEndFocusNode.dispose();
    // _licensePlateFocusNode.dispose();
    // _tourBeginFocusNode.dispose();
    // _tourEndFocusNode.dispose();
    // _roadConditionFocusNode.dispose();
    // _attendantFocusNode.dispose();
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
    print('axxxxxxxxxxxxxxxxxxxxxxxx');
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
                keyboardType: TextInputType.datetime,
                // textInputAction: TextInputAction.next,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_distanceFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['distance'] == null
                    ? ""
                    : _initValues['distance'].toString(),
                decoration: InputDecoration(labelText: 'Distanz'),
                keyboardType: TextInputType.number,
                // textInputAction: TextInputAction.next,
                // focusNode: _distanceFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_mileageBeginFocusNode);
                // },
                // validator: (value) {
                //   return null;
                // },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['mileageBegin'] == null
                    ? ""
                    : _initValues['mileageBegin'].toString(),
                decoration:
                    InputDecoration(labelText: 'Kilometerstand (Beginn)'),
                keyboardType: TextInputType.number,
                // textInputAction: TextInputAction.next,
                // focusNode: _mileageBeginFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_mileageEndFocusNode);
                // },
                // validator: (value) {
                //   if (value.isEmpty) {
                //     return 'Please enter a description.';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['mileageEnd'] == null
                    ? ""
                    : _initValues['mileageEnd'].toString(),
                decoration: InputDecoration(labelText: 'Kilometerstand (Ziel)'),
                keyboardType: TextInputType.number,
                // focusNode: _mileageEndFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_licensePlateFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['licensePlate'] == null
                    ? ""
                    : _initValues['licensePlate'],
                decoration: InputDecoration(labelText: 'Kennzeichen'),
                keyboardType: TextInputType.text,
                // focusNode: _licensePlateFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_tourBeginFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['tourBegin'] == null
                    ? ""
                    : _initValues['tourBegin'],
                decoration: InputDecoration(labelText: 'Startort'),
                keyboardType: TextInputType.text,
                // focusNode: _tourBeginFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_tourEndFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['tourEnd'] == null
                    ? ""
                    : _initValues['tourEnd'],
                decoration: InputDecoration(labelText: 'Zielort'),
                keyboardType: TextInputType.text,
                // focusNode: _tourEndFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_roadConditionFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['roadCondition'] == null
                    ? ""
                    : _initValues['roadCondition'],
                decoration:
                    InputDecoration(labelText: 'Straßenzustand/Witterung'),
                keyboardType: TextInputType.text,
                // focusNode: _roadConditionFocusNode,
                // onFieldSubmitted: (_) {
                //   FocusScope.of(context).requestFocus(_attendantFocusNode);
                // },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
                initialValue: _initValues['attendant'] == null
                    ? ""
                    : _initValues['attendant'],
                decoration: InputDecoration(labelText: 'Begleiter'),
                // keyboardType: TextInputType.text,
                // focusNode: _attendantFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Tour(
                      id: _editedProduct.id,
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
