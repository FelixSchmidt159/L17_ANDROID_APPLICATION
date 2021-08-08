import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/models/applicant.dart';
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
  final _currentUser = FirebaseAuth.instance.currentUser;
  String _selectedDriver;

  // when a applicant is deleted this method ensures that all information concenring
  // this applicant will be deleted in the database
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Fahrer löschen"),
          content: new Text("Wollen Sie diesen Fahrer wirklich löschen?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green, primary: Colors.white),
              child: Text('Ja'),
              onPressed: () async {
                Navigator.pop(context);
                if (_selectedDriver == widget.applicant.id) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Provider.of<Applicants>(context, listen: false)
                          .selectedDriverId = null;
                    }
                  });
                }
                var instance = FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser.uid)
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
                      instance
                          .collection('goals')
                          .doc(toursDocs[i].id)
                          .delete();
                    }
                  });
                  instance.delete();
                });
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
              _showDialog();
            },
          ),
        ),
      ),
    );
  }
}
