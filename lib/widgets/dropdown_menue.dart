import 'package:flutter/material.dart';
import 'package:l17/widgets/drop_down_button.dart';
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
  List<Applicant> _items;
  String _selectedApplicant;

  @override
  Widget build(BuildContext context) {
    _items = Provider.of<Applicants>(context).items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Container(
          alignment: Alignment.center,
          width: widget.width,
          height: widget.height,
          child: CustomDropdownButton(
            hint: SizedBox(
              width: widget.width * 0.75,
              child: Text(
                _items.first.name,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            value: _selectedApplicant,
            onChanged: (value) {
              setState(() {
                _selectedApplicant = value;
              });
            },
            items: _items.map((Applicant applicant) {
              return DropdownMenuItem(
                value: applicant.name,
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
            }).toList(),
          )),
    );
  }
}
