import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/screens/applicant_screen.dart';
import 'package:l17/screens/chart_bar_screen.dart';
import 'package:l17/screens/goal_screen.dart';
import 'package:l17/screens/vehicle_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.bar_chart_sharp),
            title: Text('Statistik'),
            onTap: () {
              Navigator.of(context).pushNamed(
                GoalScreen.routeName,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.show_chart_rounded),
            title: Text('Kilometerstandvorgabe'),
            onTap: () {
              Navigator.of(context).pushNamed(
                ChartBarScreen.routeName,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Fahrer'),
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
          Expanded(child: Container()),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Abmelden'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
