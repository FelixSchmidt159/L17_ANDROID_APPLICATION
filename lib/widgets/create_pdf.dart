import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';
import 'package:l17/providers/vehicle.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePdf extends StatefulWidget {
  final double height;
  final double width;

  CreatePdf(this.height, this.width);
  @override
  _CreatePdfState createState() => _CreatePdfState();
}

// class _LineChartWidgetState extends State<LineChartWidget> {
class _CreatePdfState extends State<CreatePdf> {
  List<List<String>> data = [];
  File pdfFile;
  String _selectedDriver;
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    List<Tour> tours = [];
    if (_selectedDriver != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('drivers')
          .doc(_selectedDriver)
          .collection('tours')
          .orderBy('timestamp', descending: false)
          .get()
          .then((value) {
        final toursDocs = value.docs;
        if (toursDocs.isNotEmpty) {
          for (int i = 0; i < toursDocs.length; i++) {
            tours.add(Tour(
              attendant: toursDocs[i]['attendant'],
              distance: toursDocs[i]['distance'],
              licensePlate: toursDocs[i]['licensePlate'],
              mileageBegin: toursDocs[i]['mileageBegin'],
              mileageEnd: toursDocs[i]['mileageEnd'],
              roadCondition: toursDocs[i]['roadCondition'],
              timestamp: DateTime.fromMicrosecondsSinceEpoch(
                  toursDocs[i]['timestamp'].microsecondsSinceEpoch),
              tourBegin: toursDocs[i]['tourBegin'],
              tourEnd: toursDocs[i]['tourEnd'],
              daytime: toursDocs[i]['daytime'],
              weather: toursDocs[i]['weather'],
              carName: toursDocs[i]['carName'],
            ));
          }
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('vehicles')
              .get()
              .then((value) {
            var docs = value.docs;
            if (docs.length > 0) {
              for (int i = 0; i < docs.length; i++) {
                vehicles.add(Vehicle(
                    docs[i]['name'], docs[i]['licensePlate'], docs[i].id));
              }
            }
            data = generatePdfData(tours);
            generateDocument(PdfPageFormat.a4, data).then((value) {
              if (mounted) {
                setState(() {
                  pdfFile = value;
                });
              }
            });
          });
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(8),
      child: Builder(
        builder: (context) {
          if (pdfFile != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () {
                      openFile(pdfFile);
                    }),
                Expanded(
                  child: RotatedBox(
                    child: SfPdfViewer.file(
                      pdfFile,
                    ),
                    quarterTurns: 3,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_road,
                  color: Theme.of(context).iconTheme.color,
                  size: 50,
                ),
                Text('Fügen Sie eine neue Fahrt hinzu.'),
              ],
            );
          }
        },
      ),
    );
  }

  List<List<String>> generatePdfData(List<Tour> items) {
    List<String> header = [];
    int distanceDriven = 0;
    bool match = false;
    header.add('Datum');
    header.add('Gef. KM');
    header.add('KMS Start');
    header.add('KMS Ziel');

    for (int i = 0; i < vehicles.length; i++) {
      header.add('priv. KM' +
          '\n' +
          vehicles[i].name +
          '\n' +
          vehicles[i].licensePlate);
    }
    header.add('Kfz \n Kennzeichen');
    header.add('Tageszeit');
    header.add('Fahrstrecke / -ziel');
    header.add('Straßenzustand, \n Witterung');
    header.add('Unterschrift \n Begleiter');
    header.add('Unterschrift \n Fahrer');
    List<List<String>> pdfData = [header];
    List<String> row = [];
    for (int w = 0; w < items.length; w++) {
      match = false;
      row = [];
      row.add(DateFormat.yMd('de_DE').format(items[w].timestamp));
      row.add(items[w].distance.toString() == "0"
          ? ""
          : items[w].distance.toString());
      distanceDriven += items[w].distance;
      row.add(items[w].mileageBegin.toString() == "0"
          ? ""
          : items[w].mileageBegin.toString());
      row.add(items[w].mileageEnd.toString() == "0"
          ? ""
          : items[w].mileageEnd.toString());
      for (int i = 0; i < vehicles.length; i++) {
        if (vehicles[i].licensePlate == items[w].licensePlate &&
            vehicles[i].name == items[w].carName) {
          if ((w + 1) < items.length) {
            for (int j = w + 1; j < items.length; j++) {
              if (items[j].licensePlate == items[w].licensePlate &&
                  items[j].carName == items[w].carName) {
                var diff = items[j].mileageBegin - items[w].mileageEnd;
                row.add(diff <= 0 || items[w].mileageEnd == 0
                    ? ''
                    : diff.toString());
                match = true;
                break;
              }
            }
            if (!match) row.add('');
          } else {
            row.add('');
          }
        } else {
          row.add('');
        }
      }
      row.add(items[w].licensePlate);
      row.add(items[w].daytime);
      row.add(items[w].tourBegin + ' - ' + items[w].tourEnd);
      row.add(items[w].roadCondition + ', ' + items[w].weather);
      row.add('');
      row.add('');
      pdfData.add(row);
    }
    row = [];
    for (int i = 0; i < 10 + vehicles.length; i++) {
      if (i == 1) {
        row.add('Gesamt: $distanceDriven km');
      } else
        row.add('');
    }
    pdfData.add(row);
    return pdfData;
  }

  Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }

  Future<File> mySaveDocument({
    @required String name,
    @required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return file;
  }

  Future<File> generateDocument(
      PdfPageFormat format, List<List<String>> data) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    doc.addPage(pw.MultiPage(
        pageFormat: format.copyWith(
            marginBottom: 0.5 * PdfPageFormat.cm,
            marginTop: 0.5 * PdfPageFormat.cm,
            marginLeft: 0.5 * PdfPageFormat.cm,
            marginRight: 0.5 * PdfPageFormat.cm),
        orientation: pw.PageOrientation.landscape,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text(
                  'Seite ${context.pageNumber} von ${context.pagesCount}',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (pw.Context context) => <pw.Widget>[
              pw.Header(
                  level: 0,
                  title: 'Fahrtenprotokoll',
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Text('Fahrtenprotokoll', textScaleFactor: 1),
                    ],
                  )),
              pw.Table.fromTextArray(
                context: context,
                data: data,
                oddCellStyle: pw.TextStyle(fontSize: 7),
                cellStyle: pw.TextStyle(fontSize: 7),
                headerStyle: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Padding(padding: const pw.EdgeInsets.all(0)),
            ]));

    return mySaveDocument(pdf: doc, name: 'Fahrtenbuch');
  }
}
