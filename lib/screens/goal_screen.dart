import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicants.dart';

import 'package:l17/widgets/line_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GoalScreen extends StatefulWidget {
  static const routeName = '/goal-screen';
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  double _width = 0.0;
  String _selectedDriver;
  final _currentUser = FirebaseAuth.instance.currentUser;
  int _distLastSevenDays = 0;
  int _distLastThirtyDays = 30;
  DateTime _day = DateTime.now();
  int _maxDistance = 0;

  /// fetches the tours, which are driven the last seven and thirty days
  /// and the tour with the highest driven distance
  @override
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    var now = DateTime.now();
    var tsS = Timestamp.fromDate(now.subtract(Duration(days: 7)));
    var tsN = Timestamp.fromDate(now);
    var tsT = Timestamp.fromDate(now.subtract(Duration(days: 30)));

    if (_selectedDriver != null) {
      // fetches the tours from the last seven days
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .where('timestamp',
              isLessThanOrEqualTo: tsN, isGreaterThanOrEqualTo: tsS)
          .get()
          .then((value) {
        _distLastSevenDays = 0;
        var docs = value.docs;

        for (int i = 0; i < docs.length; i++) {
          _distLastSevenDays += docs[i]['distance'];
        }
        if (mounted) {
          setState(() {});
        }
      });

      // fetches the tour with the highest driven distance
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .get()
          .then((value) {
        var docs = value.docs;
        _maxDistance = 0;
        for (int i = 0; i < docs.length; i++) {
          if (docs[i]['distance'] > _maxDistance) {
            _maxDistance = docs[i]['distance'];
            _day = DateTime.fromMicrosecondsSinceEpoch(
                docs[i]['timestamp'].microsecondsSinceEpoch);
          }
        }
        if (mounted) {
          setState(() {});
        }
      });

      // fetches the tours from the last thirty days
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .where('timestamp',
              isLessThanOrEqualTo: tsN, isGreaterThanOrEqualTo: tsT)
          .get()
          .then((value) {
        _distLastThirtyDays = 0;
        var docs = value.docs;

        for (int i = 0; i < docs.length; i++) {
          _distLastThirtyDays += docs[i]['distance'];
        }
        if (mounted) {
          setState(() {});
        }
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    var appBar = AppBar(
      title: Text('Statistik ${DateTime.now().year}'),
    );
    var height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height -
        MediaQuery.of(context).viewInsets.bottom;
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      height -= kBottomNavigationBarHeight;
    }
    return Scaffold(
      appBar: appBar,
      body: _selectedDriver != null
          ? Container(
              width: _width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LineChartWidget(),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: _width * 0.44,
                        height: height * 0.15,
                        child: Card(
                          color: Colors.grey.shade200,
                          semanticContainer: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(
                                    width: _width * 0.44 * 0.8,
                                    height: height * 0.15 * 0.35,
                                  ),
                                  Icon(Icons.directions_car)
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 0, 2),
                                child: Text(
                                  'Letzten 7 Tage',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 0, 0, 10),
                                child: Text(
                                  _distLastSevenDays.toString() + ' km',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: _width * 0.04,
                      ),
                      Container(
                        width: _width * 0.44,
                        height: height * 0.15,
                        child: Card(
                          color: Colors.grey.shade200,
                          semanticContainer: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(
                                    width: _width * 0.44 * 0.8,
                                    height: height * 0.15 * 0.35,
                                  ),
                                  Icon(
                                    Icons.directions_car,
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 0, 2),
                                child: Text(
                                  'Letzten 30 Tage',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 0, 2),
                                child: Text(
                                  _distLastThirtyDays.toString() + ' km',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Container(
                    width: _width * 0.92,
                    height: height * 0.15,
                    child: Card(
                      color: Colors.grey.shade200,
                      semanticContainer: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              SizedBox(
                                width: _width * 0.83,
                                height: height * 0.15 * 0.35,
                              ),
                              Icon(
                                Icons.directions_car,
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 2),
                            child: Text(
                              'Am ${DateFormat.Md('de_DE').format(_day)} bist du am meisten gefahren',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 10),
                            child: Text(
                              _maxDistance.toString() + ' km',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: height,
              width: _width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 50,
                  ),
                  Text('Fügen Sie einen neuen Fahrer im Side-Menü hinzu'),
                ],
              ),
            ),
    );
  }
}
