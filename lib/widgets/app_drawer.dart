import 'package:flutter/material.dart';
import 'package:l17/screens/applicant_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hallo!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Bewerber'),
            onTap: () {
              Navigator.of(context).pushNamed(
                ApplicantScreen.routeName,
                // arguments: ,
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
