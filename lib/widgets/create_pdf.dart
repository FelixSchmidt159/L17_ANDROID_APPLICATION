import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:l17/providers/tour.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';

class CreatePdf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Tour> data = [
      Tour(
          timestamp: DateTime.now(),
          distance: 101,
          licensePlate: 'VB-365 JG',
          mileageBegin: 100000,
          mileageEnd: 100005,
          roadCondition: 'nass/Regen',
          tourBegin: 'Graz',
          tourEnd: 'Graz-Stadt',
          attendant: 'Susanne Haberl'),
    ];

    generateDocument(PdfPageFormat.a4, data);
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
  print('hiiii');
  final file = File('${dir.path}/$name');

  await file.writeAsBytes(bytes);
  file.readAsLines().then((value) => print(value.first));
  return file;
}

Future<File> generateDocument(PdfPageFormat format, List<Tour> data) async {
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
            pw.Table.fromTextArray(context: context, data: const <List<String>>[
              <String>[
                'Datum',
                'Gefahrene KM',
                'Kilometerstandbeginn',
                'Kilometerstandende',
                'Kfz-Kennzeichen',
                'Tageszeit',
                'Fahrstrecke/ -ziel',
                'Straßenzustand, Witterung',
                'Unterschrift Begleiter',
                'Unterschrift Bewerber'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
              <String>[
                '1993',
                'PDF 1.0',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1',
                'Acrobat 1'
              ],
            ]),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
          ]));

  return mySaveDocument(pdf: doc, name: 'test');
}
