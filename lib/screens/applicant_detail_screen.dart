import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/providers/applicant.dart';

class ApplicantDetailScreen extends StatefulWidget {
  static const routeName = '/applicant-detail-screen';

  @override
  _ApplicantDetailScreenState createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();
  Applicant applicantObject;
  bool initialize = true;

  var _editedApplicant = Applicant("", "");

  @override
  void didChangeDependencies() {
    if (initialize) {
      applicantObject = ModalRoute.of(context).settings.arguments as Applicant;
      _editedApplicant = Applicant(applicantObject.name, applicantObject.id);
      initialize = false;
    }

    super.didChangeDependencies();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedApplicant.id == "") {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .add({
        'name': _editedApplicant.name,
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_editedApplicant.id)
          .update({
        'name': _editedApplicant.name,
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bewerber'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _editedApplicant.name,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _editedApplicant = Applicant(value, _editedApplicant.id);
                },
                decoration: InputDecoration(labelText: 'Name des Bewerbers'),
                keyboardType: TextInputType.name,
              )
            ],
          ),
        ),
      ),
    );
  }
}
