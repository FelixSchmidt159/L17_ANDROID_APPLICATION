import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l17/providers/applicants.dart';
import 'package:l17/providers/tour.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';

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
  Stream<QuerySnapshot> reference;
  StreamSubscription<QuerySnapshot> streamRef;

  @override
  void dispose() {
    if (streamRef != null) {
      streamRef.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }

  void didChangeDependencies() {
    _selectedDriver = Provider.of<Applicants>(context).selectedDriverId;
    List<Tour> tours = [];
    reference = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('drivers')
        .doc(_selectedDriver)
        .collection('tours')
        .orderBy('timestamp', descending: false)
        .snapshots();
    streamRef = reference.listen((event) {
      final toursDocs = event.docs;
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
          ));
        }

        data = generatePdfData(tours);
        generateDocument(PdfPageFormat.a4, data).then((value) {
          if (mounted) {
            setState(() {
              pdfFile = value;
            });
          }
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          IconButton(icon: Icon(Icons.file_download), onPressed: () {}),
          pdfFile != null
              ? Expanded(
                  child: RotatedBox(
                    child: SfPdfViewer.file(
                      pdfFile,
                    ),
                    quarterTurns: 3,
                  ),
                )
              : Container(),
        ],
      ),

      // TextButton(
      //   child: Text('Image PDF extern öffnen'),
      //   onPressed: () async {
      //     if (data.length > 1) {
      //       final pdfFile =
      //           await generateDocument(PdfPageFormat.a4, data);
      //       openFile(pdfFile);
      //     }
      //   },
      // ),
    );
  }
}

List<List<String>> generatePdfData(List<Tour> items) {
  List<List<String>> pdfData = [
    <String>[
      'Datum',
      'Gefahrene KM',
      'Kilometerstand (Start)',
      'Kilometerstand (Ziel)',
      'Kfz-Kennzeichen',
      'Tageszeit',
      'Fahrstrecke / -ziel',
      'Straßenzustand',
      'Unterschrift Begleiter',
      'Unterschrift Bewerber'
    ]
  ];
  for (Tour tour in items) {
    pdfData.add(<String>[
      DateFormat.yMd('de_DE').format(tour.timestamp),
      tour.distance.toString(),
      tour.mileageBegin.toString(),
      tour.mileageEnd.toString(),
      tour.licensePlate,
      tour.daytime,
      tour.tourBegin + ' - ' + tour.tourEnd,
      tour.roadCondition,
      '',
      '',
    ]);
  }
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
      pageFormat: format.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      orientation: pw.PageOrientation.landscape,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      // header: (pw.Context context) {
      //   if (context.pageNumber == 1) {
      //     return pw.SizedBox();
      //   }
      //   return pw.Container(
      //       alignment: pw.Alignment.centerRight,
      //       margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      //       padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      //       decoration: const pw.BoxDecoration(
      //           border: pw.Border(
      //               bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey))),
      //       child: pw.Text('Portable Document Format',
      //           style: pw.Theme.of(context)
      //               .defaultTextStyle
      //               .copyWith(color: PdfColors.grey)));
      // },
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
