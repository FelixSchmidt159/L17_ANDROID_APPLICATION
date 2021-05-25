import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicants.dart';
import 'package:provider/provider.dart';

class ChartBarScreen extends StatefulWidget {
  static const routeName = '/chart-bar-screen';
  @override
  _ChartBarScreenState createState() => _ChartBarScreenState();
}

class _ChartBarScreenState extends State<ChartBarScreen> {
  String _selectedDriver;
  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    super.didChangeDependencies();
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  final appBar = AppBar(
    title: Text('Fortschritt'),
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
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar,
      body: _selectedDriver != null || _selectedDriver != ""
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('drivers')
                  .doc(_selectedDriver)
                  .collection('goals')
                  .snapshots(),
              builder: (ctx, toursSnapshot) {
                if (toursSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: height * 0.90,
                    width: width,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final toursDocs = toursSnapshot.data.docs;
                return Container();
              },
            )
          : Container(
              height: height * 0.90,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 50,
                  ),
                  Text('Fügen Sie einen neuen Fahrer im Side-Menü hinzu.'),
                ],
              ),
            ),
    );
  }
}
