import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/vehicle.dart';
import 'package:l17/screens/vehicle_detail_screen.dart';
import 'package:l17/widgets/vehicle_list_item.dart';

class VehicleScreen extends StatefulWidget {
  static const routeName = '/vehicle-screen';
  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final appBar = AppBar(
    title: Text('Fahrzeuge'),
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
    return Scaffold(
      appBar: appBar,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('/users/' + currentUser.uid + '/vehicles')
            .snapshots(),
        builder: (ctx, toursSnapshot) {
          if (toursSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: height * 0.90,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final toursDocs = toursSnapshot.data.docs;
          return Container(
            height: height,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return VehicleListItem(
                        Vehicle(
                          toursDocs[index]['name'],
                          toursDocs[index]['licensePlate'],
                          toursDocs[index].id,
                        ),
                      );
                    },
                    itemCount: toursDocs.length,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          VehicleDetailScreen.routeName,
                          arguments: Vehicle("", "", ""));
                    },
                    child: Text('Fahrzeug hinzufügen'))
              ],
            ),
          );
        },
      ),
    );
  }
}
