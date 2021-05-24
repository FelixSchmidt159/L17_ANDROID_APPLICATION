import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/vehicle.dart';
import 'package:l17/screens/vehicle_detail_screen.dart';

class VehicleListItem extends StatefulWidget {
  final Vehicle vehicle;

  VehicleListItem(this.vehicle);

  @override
  _VehicleListItemState createState() => _VehicleListItemState();
}

class _VehicleListItemState extends State<VehicleListItem> {
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(VehicleDetailScreen.routeName,
            arguments: Vehicle(widget.vehicle.name, widget.vehicle.licensePlate,
                widget.vehicle.id));
      },
      child: Card(
        child: ListTile(
          leading: Icon(Icons.directions_car),
          title: Text("${widget.vehicle.name}, ${widget.vehicle.licensePlate}"),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              size: 25,
            ),
            color: Theme.of(context).errorColor,
            onPressed: () async {
              var instance = FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser.uid)
                  .collection('vehicles')
                  .doc(widget.vehicle.id);
              instance.delete();
            },
          ),
        ),
      ),
    );
  }
}
