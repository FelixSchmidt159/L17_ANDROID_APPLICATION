import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l17/providers/tour.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePdf extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    List<List<String>> data;
    List<Tour> tours = [];
    FirebaseFirestore.instance
        .collection('/users/' + currentUser.uid + '/tours')
        .snapshots()
        .listen((event) {
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
          ));
        }
        data = generatePdfData(tours);

        generateDocument(PdfPageFormat.a4, data);
      }
    });

    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              child: Text('Image PDF extern öffnen'),
              onPressed: () async {
                final pdfFile = await generateDocument(PdfPageFormat.a4, data);
                openFile(pdfFile);
              },
            ),
          ],
        ),
      ),
    );
  }
}

List<List<String>> generatePdfData(List<Tour> items) {
  List<List<String>> pdfData = [
    <String>[
      'Datum',
      'Gefahrene KM',
      'Kilometerstand  ',
      'Kennzeichen  ',
      'Tageszeit  ',
      'Fahrstrecke / ziel',
      'Straßenzustand, Witterung',
      'Unterschrift Begleiter',
      'Unterschrift Bewerber'
    ]
  ];

  for (Tour tour in items) {
    pdfData.add(<String>[
      DateFormat.yMd('de_DE').format(tour.timestamp),
      tour.distance.toString(),
      tour.mileageBegin.toString() + ' / ' + tour.mileageEnd.toString(),
      tour.licensePlate,
      DateFormat.Hm().format(tour.timestamp),
      tour.tourBegin + ' / ' + tour.tourEnd,
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
  print(dir.absolute);
  final file = File('${dir.path}/$name');

  await file.writeAsBytes(bytes);
  // file.readAsLines().then((value) => print(value.first));
  return file;
}

Future<File> generateDocument(
    PdfPageFormat format, List<List<String>> data) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  // final font1 = await rootBundle.load('assets/open-sans.ttf');
  // final font2 = await rootBundle.load('assets/open-sans-bold.ttf');

  doc.addPage(pw.MultiPage(
      // theme: pw.ThemeData.withFont(
      //   base: pw.Font.ttf(font1),
      //   bold: pw.Font.ttf(font2),
      // ),
      pageFormat: format.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      orientation: pw.PageOrientation.landscape,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey))),
            child: pw.Text('Portable Document Format',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
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
                      pw.Text('Fahrtenprotokoll', textScaleFactor: 2),
                    ])),
            pw.Table.fromTextArray(context: context, data: data),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
          ]));

  return mySaveDocument(pdf: doc, name: 'test');
}
