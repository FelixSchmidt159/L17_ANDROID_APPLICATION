import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l17/models/TourScreenArguments.dart';

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
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
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
          title: Text(
            widget.tour.tourBegin + " - " + widget.tour.tourEnd,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat.yMMMd('de_DE').format(widget.tour.timestamp),
          ),
          trailing: MediaQuery.of(context).size.width > 460
              ? TextButton.icon(
                  style: TextButton.styleFrom(
                      primary: Theme.of(context).errorColor),
                  icon: Icon(
                    Icons.delete,
                    size: 25,
                  ),
                  label: Text('Delete'),
                  onPressed: () {
                    print(widget.id);
                    FirebaseFirestore.instance
                        .collection('/users/' + currentUser.uid + '/tours')
                        .doc(widget.id)
                        .delete();
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 25,
                  ),
                  color: Theme.of(context).errorColor,
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('/users/' + currentUser.uid + '/tours')
                        .doc(widget.id)
                        .delete();
                  },
                ),
        ),
      ),
    );
  }
}
