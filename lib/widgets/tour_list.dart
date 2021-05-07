import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/tour.dart';
import 'package:l17/widgets/chart_bar.dart';
import 'package:l17/widgets/dropdown_menue.dart';
import 'package:l17/widgets/tour_list_item.dart';

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

  @override
  void didChangeDependencies() {
    // _overallDistance = 0;
    FirebaseFirestore.instance
        .collection('/users/' + currentUser.uid + '/tours')
        .snapshots()
        .listen((event) {
      final toursDocs = event.docs;
      if (toursDocs.isNotEmpty) {
        _overallDistance = 0;
        for (int i = 0; i < toursDocs.length; i++) {
          _overallDistance += toursDocs[i]['distance'];
        }
        setState(() {});
      }
    });
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
              ChartBar(_overallDistance, 3000, widget.height * 0.10),
              SizedBox(
                width: widget.width * 0.05,
              ),
              Container(
                width: widget.width * 0.25,
                alignment: Alignment.center,
                child: Text(
                  '$_overallDistance km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('/users/' + currentUser.uid + '/tours')
              .snapshots(),
          builder: (ctx, toursSnapshot) {
            if (toursSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: widget.height * 0.90,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final toursDocs = toursSnapshot.data.docs;
            return Container(
              height: widget.height * 0.90,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return TourListItem(
                      Tour(
                          timestamp: DateTime.fromMicrosecondsSinceEpoch(
                              toursDocs[index]['timestamp']
                                  .microsecondsSinceEpoch),
                          attendant: toursDocs[index]['attendant'],
                          distance: toursDocs[index]['distance'],
                          licensePlate: toursDocs[index]['licensePlate'],
                          mileageBegin: toursDocs[index]['mileageBegin'],
                          mileageEnd: toursDocs[index]['mileageEnd'],
                          roadCondition: toursDocs[index]['roadCondition'],
                          tourBegin: toursDocs[index]['tourBegin'],
                          tourEnd: toursDocs[index]['tourEnd']),
                      toursDocs[index].id);
                },
                itemCount: toursDocs.length,
              ),
            );
          },
        )
      ],
    );
  }
}
