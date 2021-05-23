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
  @override
  final currentUser = FirebaseAuth.instance.currentUser;

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
              // if (_selectedDriver == widget.applicant.id) {
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     Provider.of<Applicants>(context, listen: false)
              //         .selectedDriverId = null;
              //   });
              // }
              // var instance = FirebaseFirestore.instance
              //     .collection('users')
              //     .doc(currentUser.uid)
              //     .collection('drivers')
              //     .doc(widget.applicant.id);

              // await instance.collection('tours').get().then((value) {
              //   final toursDocs = value.docs;
              //   for (int i = 0; i < toursDocs.length; i++) {
              //     instance.collection('tours').doc(toursDocs[i].id).delete();
              //   }
              //   instance.delete();
              // });
            },
          ),
        ),
      ),
    );
    // Divider();
  }
}
