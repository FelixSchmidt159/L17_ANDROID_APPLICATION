import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicant.dart';
import 'package:l17/screens/applicant_detail_screen.dart';
import 'package:l17/widgets/applicant_list_item.dart';

class ApplicantScreen extends StatefulWidget {
  static const routeName = '/applicant-screen';
  @override
  _ApplicantScreenState createState() => _ApplicantScreenState();
}

class _ApplicantScreenState extends State<ApplicantScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final appBar = AppBar(
    title: Text('Fahrer'),
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
            .collection('/users/' + currentUser.uid + '/drivers')
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
                      return ApplicantListItem(Applicant(
                          toursDocs[index]['name'], toursDocs[index].id));
                    },
                    itemCount: toursDocs.length,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          ApplicantDetailScreen.routeName,
                          arguments: Applicant("", ""));
                    },
                    child: Text('Bewerber hinzufügen'))
              ],
            ),
          );
        },
      ),
    );
  }
}
