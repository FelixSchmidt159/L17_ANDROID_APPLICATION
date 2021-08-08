import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l17/models/applicant.dart';

class ApplicantDetailScreen extends StatefulWidget {
  static const routeName = '/applicant-detail-screen';

  @override
  _ApplicantDetailScreenState createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _form = GlobalKey<FormState>();
  bool _initialize = true;
  Applicant _editedApplicant;

  @override
  void didChangeDependencies() {
    if (_initialize) {
      _editedApplicant = ModalRoute.of(context).settings.arguments as Applicant;
      _initialize = false;
    }

    super.didChangeDependencies();
  }

  /// Creates a new applicant document if it doesn´t already exist
  /// otherwise it will update the given document referenced by the id
  /// an empty string as an id means the applicant document doesn´t exist yet
  Future<bool> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return false;
    }
    _form.currentState.save();
    if (_editedApplicant.id == "") {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .add({
        'name': _editedApplicant.name,
      });
      return true;
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('drivers')
          .doc(_editedApplicant.id)
          .update({
        'name': _editedApplicant.name,
      });
      return true;
    }
  }

  Future<bool> _onWillPop() async {
    return (_saveForm()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fahrer'),
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
                    if (value.length > 20)
                      return 'Ein Name besteht aus maximal 20 Zeichen';
                    return null;
                  },
                  onSaved: (value) {
                    _editedApplicant = Applicant(value, _editedApplicant.id);
                  },
                  decoration: InputDecoration(labelText: 'Name des Fahrers'),
                  keyboardType: TextInputType.name,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
