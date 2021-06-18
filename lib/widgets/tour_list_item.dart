import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';
import 'package:l17/providers/applicants.dart';
import 'package:provider/provider.dart';

import '../screens/tour_screen.dart';
import '../providers/tour.dart';

class TourListItem extends StatefulWidget {
  final Tour tour;
  final String id;

  TourListItem(this.tour, this.id);

  @override
  _TourListItemState createState() => _TourListItemState();
}

class _TourListItemState extends State<TourListItem> {
  String _selectedDriver;
  final currentUser = FirebaseAuth.instance.currentUser;

  bool checkMissingFields() {
    bool missingFields = false;
    if (widget.tour.attendant == "") missingFields = true;
    if (widget.tour.daytime == "") missingFields = true;
    if (widget.tour.distance == 0) missingFields = true;
    if (widget.tour.licensePlate == "") missingFields = true;
    if (widget.tour.mileageBegin == 0) missingFields = true;
    if (widget.tour.mileageEnd == 0) missingFields = true;
    if (widget.tour.roadCondition == "") missingFields = true;
    if (widget.tour.tourBegin == "") missingFields = true;
    if (widget.tour.tourEnd == "") missingFields = true;
    if (widget.tour.weather == "") missingFields = true;
    return missingFields;
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Fahrt löschen"),
          content: new Text("Wollen Sie diese Fahrt wirklich löschen?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green, primary: Colors.white),
              child: Text('Ja'),
              onPressed: () {
                Navigator.pop(context);
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('drivers')
                    .doc(_selectedDriver)
                    .collection('tours')
                    .doc(widget.id)
                    .delete();
                setState(() {});
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, primary: Colors.white),
              child: Text('Nein'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(TourScreen.routeName,
            arguments: TourScreenArguments(widget.tour, widget.id));
      },
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 5,
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: FittedBox(
                child: Text(widget.tour.distance.toString() + 'km'),
              ),
            ),
          ),
          title: checkMissingFields()
              ? Row(
                  children: [
                    Text(
                      'Fahrt abschließen  ',
                      style: TextStyle(
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                          color: Theme.of(context).errorColor),
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).errorColor,
                      radius: 10,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: FittedBox(
                          child: Text(
                            '!',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Text(
                  widget.tour.tourBegin + " - " + widget.tour.tourEnd,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          subtitle: Text(
            DateFormat.yMMMd('de_DE').format(widget.tour.timestamp),
          ),
          trailing: FittedBox(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 25,
                  ),
                  color: Theme.of(context).errorColor,
                  onPressed: () {
                    if (_selectedDriver != null) {
                      _showDialog();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
