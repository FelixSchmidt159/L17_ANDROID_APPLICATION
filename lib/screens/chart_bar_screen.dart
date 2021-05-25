import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/widgets/chart_bar.dart';
import 'package:provider/provider.dart';

class ChartBarScreen extends StatefulWidget {
  static const routeName = '/chart-bar-screen';
  @override
  _ChartBarScreenState createState() => _ChartBarScreenState();
}

class _ChartBarScreenState extends State<ChartBarScreen> {
  String _selectedDriver;
  int _overallDistance = 0;
  Stream<QuerySnapshot> reference;
  StreamSubscription<QuerySnapshot> streamRef;
  final currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    _overallDistance = 0;
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
          _overallDistance = 0;
          for (int i = 0; i < toursDocs.length; i++) {
            _overallDistance += toursDocs[i]['distance'];
          }
          if (mounted) {
            setState(() {
              _overallDistance = _overallDistance;
            });
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
    super.dispose();
  }

  final appBar = AppBar(
    title: Text('Fortschritt'),
  );
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).viewInsets.bottom;
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      height -= kBottomNavigationBarHeight;
    }
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar,
      body: _selectedDriver != null || _selectedDriver != ""
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('drivers')
                  .doc(_selectedDriver)
                  .collection('goals')
                  .snapshots(),
              builder: (ctx, toursSnapshot) {
                if (toursSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: height * 0.90,
                    width: width,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final toursDocs = toursSnapshot.data.docs;
                if (toursDocs)
                  return Container(
                    height: height,
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _form,
                            child: ListView(
                              children: <Widget>[
                                TextFormField(
                                  initialValue: _editedVehicle.name,
                                  validator: (value) {
                                    if (value.length >= 20)
                                      return 'Der Name ist zu lange';
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _editedVehicle = Vehicle(
                                      value,
                                      _editedVehicle.licensePlate,
                                      _editedVehicle.id,
                                    );
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Fahrzeug'),
                                  keyboardType: TextInputType.name,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 55, 8, 8),
                          child: ChartBar(_overallDistance, 3000,
                              height * 0.1 * 0.5, width * 0.9),
                        ),
                      ],
                    ),
                  );
              },
            )
          : Container(
              height: height * 0.90,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 50,
                  ),
                  Text('Fügen Sie einen neuen Fahrer im Side-Menü hinzu.'),
                ],
              ),
            ),
    );
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
}
