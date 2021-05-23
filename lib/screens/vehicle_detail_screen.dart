import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/vehicle.dart';

class VehicleDetailScreen extends StatefulWidget {
  static const routeName = '/vehicle-detail-screen';
  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();
  Vehicle vehicle;
  bool initialize = true;

  var _editedVehicle = Vehicle("", "", "");

  @override
  void didChangeDependencies() {
    if (initialize) {
      vehicle = ModalRoute.of(context).settings.arguments as Vehicle;
      _editedVehicle = Vehicle(vehicle.name, vehicle.licensePlate, vehicle.id);
      initialize = false;
    }

    super.didChangeDependencies();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedVehicle.id == "") {
      FirebaseFirestore.instance
          .collection('/users/' + currentUser.uid + '/vehicles')
          .add({
        'name': _editedVehicle.name,
        'licensePlate': _editedVehicle.licensePlate,
      });
    } else {
      FirebaseFirestore.instance
          .collection('/users/' + currentUser.uid + '/vehicles')
          .doc(_editedVehicle.id)
          .update({
        'name': _editedVehicle.name,
        'licensePlate': _editedVehicle.licensePlate,
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fahrzeuge'),
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
                initialValue: _editedVehicle.name,
                validator: (value) {
                  if (value == null)
                    return 'Geben Sie ein Kennzeichen im Format XX-XXXXX an';

                  if (value.length >= 15) return 'Das Kennzeichen ist zu lange';
                  if (!value.contains('-'))
                    return 'Geben Sie ein Kennzeichen im Format XX-XXXXX an';

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
                  if (value.length >= 20) return 'Der Name ist zu lange';
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
    );
  }
}
