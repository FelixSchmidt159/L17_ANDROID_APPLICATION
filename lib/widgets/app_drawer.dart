import 'package:flutter/material.dart';
import 'package:l17/screens/applicant_screen.dart';
import 'package:l17/screens/goal_screen.dart';
import 'package:l17/screens/vehicle_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            // title: Text('Hallo!'),
            automaticallyImplyLeading: false,
          ),
          // Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Bewerber'),
            onTap: () {
              Navigator.of(context).pushNamed(
                ApplicantScreen.routeName,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Fahrzeuge'),
            onTap: () {
              Navigator.of(context).pushNamed(
                VehicleScreen.routeName,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bar_chart_sharp),
            title: Text('Ziel'),
            onTap: () {
              Navigator.of(context).pushNamed(
                GoalScreen.routeName,
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
