import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/applicant.dart';
import '../providers/applicants.dart';

class DropDownMenue extends StatefulWidget {
  final double width;
  final double height;

  DropDownMenue(this.width, this.height);
  @override
  _DropDownMenueState createState() => _DropDownMenueState();
}

class _DropDownMenueState extends State<DropDownMenue> {
  var currentUser = FirebaseAuth.instance.currentUser;
  List<Applicant> _items = [];
  String _selectedDriver;
  bool init = true;

  @override
  Widget build(BuildContext context) {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    print(_selectedDriver);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('/users/' + currentUser.uid + '/drivers')
          .snapshots(),
      builder: (ctx, toursSnapshot) {
        if (toursSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        _items = [];
        final toursDocs = toursSnapshot.data.docs;
        for (int i = 0; i < toursDocs.length; i++) {
          _items.add(Applicant(toursDocs[i]['name'], toursDocs[i].id));
        }
        init = true;

        var dropdownMenuItemList =
            _items.map<DropdownMenuItem<String>>((Applicant applicant) {
          if (applicant.id == _selectedDriver) {
            init = false;
          }
          return DropdownMenuItem<String>(
            value: applicant.id,
            child: SizedBox(
              width: widget.width * 0.75,
              child: Text(
                applicant.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList();

        if (init) {
          _selectedDriver = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<Applicants>(context, listen: false).selectedDriverId =
                _selectedDriver;
          });
        }

        if (_selectedDriver == null) {
          if (dropdownMenuItemList.length > 0) {
            _selectedDriver = dropdownMenuItemList[0].value;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<Applicants>(context, listen: false).selectedDriverId =
                  _selectedDriver;
            });
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Container(
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height,
            child: DropdownButton<String>(
              hint: SizedBox(
                  width: widget.width * 0.75,
                  child: Text(
                    '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  )),
              value: _selectedDriver,
              onChanged: (String value) {
                if (value != null) {
                  setState(() {
                    _selectedDriver = value;
                    Provider.of<Applicants>(context, listen: false)
                        .selectedDriverId = value;
                  });
                }
              },
              items: dropdownMenuItemList,
            ),
          ),
        );
      },
    );
  }
}
