import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';
import 'package:l17/widgets/chart_bar.dart';
import 'package:l17/widgets/dropdown_menue.dart';
import 'package:l17/widgets/tour_list_item.dart';
import 'package:provider/provider.dart';

class TourList extends StatefulWidget {
  final double height;
  final double width;

  TourList(this.height, this.width);

  @override
  _TourListState createState() => _TourListState();
}

class _TourListState extends State<TourList> {
  int _overallDistance;
  var currentUser = FirebaseAuth.instance.currentUser;
  String _selectedDriver;
  Stream<QuerySnapshot> reference;
  StreamSubscription<QuerySnapshot> streamRef;
  @override
  void dispose() {
    if (streamRef != null) {
      streamRef.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
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
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey.shade200,
          height: widget.height * 0.10,
          // padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropDownMenue(widget.width * 0.25, widget.height * 0.10),
              SizedBox(
                width: widget.width * 0.05,
              ),
              ChartBar(_overallDistance, 3000, widget.height * 0.10 * 0.25,
                  widget.width * 0.30),
              SizedBox(
                width: widget.width * 0.05,
              ),
              Container(
                width: widget.width * 0.25,
                alignment: Alignment.center,
                child: _overallDistance != 0
                    ? Text(
                        '$_overallDistance km',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
        _selectedDriver != null
            ? StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('drivers')
                    .doc(_selectedDriver)
                    .collection('tours')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (ctx, toursSnapshot) {
                  if (toursSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      _selectedDriver != null) {
                    return Container(
                      height: widget.height * 0.90,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final toursDocs = toursSnapshot.data.docs;
                  return toursDocs.length > 0
                      ? Container(
                          height: widget.height * 0.90,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return TourListItem(
                                  Tour(
                                      timestamp:
                                          DateTime.fromMicrosecondsSinceEpoch(
                                              toursDocs[index]['timestamp']
                                                  .microsecondsSinceEpoch),
                                      attendant: toursDocs[index]['attendant'],
                                      distance: toursDocs[index]['distance'],
                                      licensePlate: toursDocs[index]
                                          ['licensePlate'],
                                      mileageBegin: toursDocs[index]
                                          ['mileageBegin'],
                                      mileageEnd: toursDocs[index]
                                          ['mileageEnd'],
                                      roadCondition: toursDocs[index]
                                          ['roadCondition'],
                                      tourBegin: toursDocs[index]['tourBegin'],
                                      tourEnd: toursDocs[index]['tourEnd'],
                                      daytime: toursDocs[index]['daytime']),
                                  toursDocs[index].id);
                            },
                            itemCount: toursDocs.length,
                          ),
                        )
                      : Container(
                          height: widget.height * 0.90,
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
                        );
                },
              )
            : Container(
                height: widget.height * 0.90,
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
              )
      ],
    );
  }
}
