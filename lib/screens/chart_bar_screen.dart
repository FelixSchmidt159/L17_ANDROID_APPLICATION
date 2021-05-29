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

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    if (_init) {
      _overallDistance = 0;
      if (_selectedDriver != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('tours')
            .get()
            .then((value) {
          final toursDocs = value.docs;
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
      }
      _init = false;

      if (_selectedDriver != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .collection('drivers')
            .doc(_selectedDriver)
            .collection('goals')
            .get()
            .then((value) {
          var docs = value.docs;
          if (mounted) {
            setState(() {
              if (value.docs.length >= 1) {
                _distanceController.text = docs[0]['goal'].toString();
                _distanceGoal = docs[0]['goal'];
                _distanceGoalId = docs[0].id;
              }
            });
          }
        });
      }
    }

    super.didChangeDependencies();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
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
        }).then((value) {
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Ziel'),
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _saveForm,
        )
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
    return Scaffold(
      appBar: appBar,
      body: _selectedDriver != null
          ? ListView(children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Setzen Sie sich ein Ziel für das Jahr ${DateTime.now().year}',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 25, 8, 8),
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
                            return 'Sie können nur Ziele bis 100000 km definieren.';
                          if (int.parse(value) < 0)
                            return 'Sie können nur positive Zahlen als Ziel definieren.';
                          return null;
                        },
                        onSaved: (value) {
                          _distanceGoal = int.parse(value);
                        },
                        decoration: InputDecoration(labelText: 'Ziel [km]'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
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
    );
  }
}
