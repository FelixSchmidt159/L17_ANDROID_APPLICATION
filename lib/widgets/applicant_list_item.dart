import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicant.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/screens/applicant_detail_screen.dart';
import 'package:provider/provider.dart';

class ApplicantListItem extends StatefulWidget {
  final Applicant applicant;

  ApplicantListItem(this.applicant);

  @override
  _ApplicantListItemState createState() => _ApplicantListItemState();
}

class _ApplicantListItemState extends State<ApplicantListItem> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String _selectedDriver;
  @override
  Widget build(BuildContext context) {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ApplicantDetailScreen.routeName,
            arguments: Applicant(widget.applicant.name, widget.applicant.id));
      },
      child: Card(
        child: ListTile(
          leading: Icon(Icons.people),
          title: Text(widget.applicant.name),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              size: 25,
            ),
            color: Theme.of(context).errorColor,
            onPressed: () async {
              if (_selectedDriver == widget.applicant.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<Applicants>(context, listen: false)
                      .selectedDriverId = null;
                });
              }
              var instance = FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('drivers')
                  .doc(widget.applicant.id);

              await instance.collection('tours').get().then((value) {
                final toursDocs = value.docs;
                for (int i = 0; i < toursDocs.length; i++) {
                  instance.collection('tours').doc(toursDocs[i].id).delete();
                }
                instance.collection('goals').get().then((value) {
                  final toursDocs = value.docs;
                  for (int i = 0; i < toursDocs.length; i++) {
                    instance.collection('goals').doc(toursDocs[i].id).delete();
                  }
                });
                instance.delete();
              });
            },
          ),
        ),
      ),
    );
    // Divider();
  }
}
