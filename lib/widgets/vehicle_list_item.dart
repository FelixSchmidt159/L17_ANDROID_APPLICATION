import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/models/vehicle.dart';
import 'package:l17/screens/vehicle_detail_screen.dart';

class VehicleListItem extends StatefulWidget {
  final Vehicle vehicle;

  VehicleListItem(this.vehicle);

  @override
  _VehicleListItemState createState() => _VehicleListItemState();
}

class _VehicleListItemState extends State<VehicleListItem> {
  final _currentUser = FirebaseAuth.instance.currentUser;

  // delete a vehicle
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Fahrzeug löschen"),
          content: new Text("Wollen Sie dieses Fahrzeug wirklich löschen?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green, primary: Colors.white),
              child: Text('Ja'),
              onPressed: () {
                Navigator.pop(context);
                var instance = FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser.uid)
                    .collection('vehicles')
                    .doc(widget.vehicle.id);
                instance.delete();
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
              _showDialog();
            },
          ),
        ),
      ),
    );
  }
}
