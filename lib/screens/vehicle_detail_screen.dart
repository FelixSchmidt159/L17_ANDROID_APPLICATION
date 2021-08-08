import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/models/vehicle.dart';

class VehicleDetailScreen extends StatefulWidget {
  static const routeName = '/vehicle-detail-screen';
  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();
  Vehicle _vehicle;
  bool _initialize = true;
  StreamSubscription<QuerySnapshot> _vehicleListener;
  List<Vehicle> _vehicles = [];
  Vehicle _editedVehicle = Vehicle("", "", "");

  // fetches all vehicles
  @override
  void didChangeDependencies() {
    if (_initialize) {
      _vehicle = ModalRoute.of(context).settings.arguments as Vehicle;
      _editedVehicle =
          Vehicle(_vehicle.name, _vehicle.licensePlate, _vehicle.id);
      _initialize = false;
      _vehicleListener = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('vehicles')
          .snapshots()
          .listen((event) {
        var docs = event.docs;
        if (docs.isNotEmpty) {
          for (int i = 0; i < docs.length; i++) {
            _vehicles.add(
                Vehicle(docs[i]['name'], docs[i]['licensePlate'], docs[i].id));
          }
          setState(() {});
        }
      });
    }

    super.didChangeDependencies();
  }

  // cancel subscribtion to avoid memory leaks
  @override
  void dispose() {
    if (_vehicleListener != null) _vehicleListener.cancel();
    super.dispose();
  }

  // stores or updates an vehicle document depending on if it already exists
  Future<bool> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return false;
    }
    _form.currentState.save();
    if (_editedVehicle.id == "") {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('vehicles')
          .add({
        'name': _editedVehicle.name,
        'licensePlate': _editedVehicle.licensePlate,
        'lastMileage': 0,
      });
      return true;
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('vehicles')
          .doc(_editedVehicle.id)
          .update({
        'name': _editedVehicle.name,
        'licensePlate': _editedVehicle.licensePlate,
        'lastMileage': 0,
      });
      return true;
    }
  }

  Future<bool> _onWillPop() async {
    return (_saveForm()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fahrzeuge'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: _editedVehicle.name,
                  validator: (value) {
                    if (value.length > 20)
                      return 'Der Name darf nicht länger als 20 Zeichen sein';
                    if (value.isEmpty) return 'Geben Sie einen Namen ein';
                    for (int i = 0; i < _vehicles.length; i++) {
                      if (value.toLowerCase() ==
                              _vehicles[i].name.toLowerCase() &&
                          _vehicle.id == "")
                        return 'Dieser Namer existiert bereits';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedVehicle = Vehicle(
                      value,
                      _editedVehicle.licensePlate,
                      _editedVehicle.id,
                    );
                  },
                  decoration: InputDecoration(labelText: 'Fahrzeug'),
                  keyboardType: TextInputType.name,
                ),
                TextFormField(
                  initialValue: _editedVehicle.licensePlate,
                  validator: (value) {
                    if (value.isEmpty) return 'Geben Sie das Kennzeichen ein';
                    if (value.length >= 15)
                      return 'Das Kennzeichen ist zu lange';

                    return null;
                  },
                  onSaved: (value) {
                    _editedVehicle = Vehicle(
                      _editedVehicle.name,
                      value,
                      _editedVehicle.id,
                    );
                  },
                  decoration: InputDecoration(labelText: 'Kennzeichen'),
                  keyboardType: TextInputType.name,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
