import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:l17/providers/applicants.dart';
import 'package:l17/widgets/chart_bar.dart';

class ChartBarScreen extends StatefulWidget {
  static const routeName = '/chart-bar-screen';
  @override
  _ChartBarScreenState createState() => _ChartBarScreenState();
}

class _ChartBarScreenState extends State<ChartBarScreen> {
  String _selectedDriver;
  int _overallDistance = 0;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();
  final TextEditingController _distanceController = TextEditingController();
  bool _init = true;
  String _distanceGoalId;
  int _distanceGoal = 0;
  StreamSubscription<QuerySnapshot> _distanceListener;
  StreamSubscription<QuerySnapshot> _goalListener;

  @override
  void dispose() {
    if (_goalListener != null) _goalListener.cancel();
    if (_distanceListener != null) _distanceListener.cancel();
    _distanceController.dispose();
    super.dispose();
  }

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;

    if (_selectedDriver != null && _init) {
      _distanceListener = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .snapshots()
          .listen((event) {
        final toursDocs = event.docs;
        if (toursDocs.isNotEmpty) {
          _overallDistance = 0;
          for (int i = 0; i < toursDocs.length; i++) {
            _overallDistance += toursDocs[i]['distance'];
          }
          if (mounted) {
            setState(() {});
          }
        }
      });

      _goalListener = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('goals')
          .snapshots()
          .listen((event) {
        var docs = event.docs;
        if (mounted) {
          setState(() {
            if (event.docs.length >= 1) {
              _distanceController.text = docs[0]['goal'].toString();
              _distanceGoal = docs[0]['goal'];
              _distanceGoalId = docs[0].id;
            }
          });
        }
      });
      _init = false;
    }

    super.didChangeDependencies();
  }

  Future<bool> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return false;
    }
    _form.currentState.save();
    if (_selectedDriver != null) {
      if (_distanceGoalId == null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('goals')
            .add({
          'goal': _distanceGoal,
        }).then((value) {
          setState(() {
            _distanceGoalId = value.id;
          });
        });
        return true;
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('goals')
            .doc(_distanceGoalId)
            .update({
          'goal': _distanceGoal,
        });
        return true;
      }
    }
    return true;
  }

  Future<bool> _onWillPop() async {
    return (_saveForm()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Ziel'),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.save),
        //   onPressed: _saveForm,
        // )
      ],
    );
    var height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).viewInsets.bottom;
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      height -= kBottomNavigationBarHeight;
    }
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: _selectedDriver != null
            ? ListView(children: <Widget>[
                _overallDistance != 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 40, 10, 5),
                            child: Text(
                              'Kilometerstandvorgabe festlegen',
                              style: Theme.of(context).textTheme.headline1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100, 5, 100, 20),
                            child: Text(
                              'Setzen Sie den Kilometerstand fest, den Sie erreichen möchten',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 15, 8, 8),
                            child: ChartBar(_overallDistance, _distanceGoal,
                                height * 0.1 * 0.5, width * 0.9),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
                            child: Form(
                              key: _form,
                              child: TextFormField(
                                controller: _distanceController,
                                validator: (value) {
                                  if (num.tryParse(value) == null)
                                    return 'Geben Sie das Ziel als Ganzzahl an.';
                                  if (int.parse(value) > 64000)
                                    return 'Sie können nur Ziele bis 64000 km definieren.';
                                  if (int.parse(value) < 0)
                                    return 'Sie können nur positive Zahlen als Ziel definieren.';
                                  return null;
                                },
                                onChanged: (value) {
                                  if (num.tryParse(value) != null) {
                                    _distanceGoal = int.parse(value);
                                    setState(() {});
                                  }
                                },
                                onSaved: (value) {
                                  _distanceGoal = int.parse(value);
                                },
                                decoration:
                                    InputDecoration(labelText: 'Ziel [km]'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: height * 0.90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_road,
                              color: Theme.of(context).iconTheme.color,
                              size: 50,
                            ),
                            Text('Fügen Sie eine neue Fahrt hinzu.'),
                          ],
                        ),
                      )
              ])
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
      ),
    );
  }
}
