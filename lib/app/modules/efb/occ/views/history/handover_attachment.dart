import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../../../occ/views/history/detail_history_device_view.dart';

Future<void> generateLogPdfDevice1() async {
  final pdf = pw.Document();

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/log_device1.pdf");

  final ByteData logo =
      await rootBundle.load('assets/images/airasia_logo_circle.png');
  final Uint8List uint8list = logo.buffer.asUint8List();

  final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  final footer = pw.Container(
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('IAA/FOP/F/001'),
        ),
        pw.Spacer(),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('PT Indonesia AirAsia'),
        ),
      ],
    ),
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter.copyWith(
        marginLeft: 72.0,
        marginRight: 72.0,
        marginTop: 36.0,
        marginBottom: 72.0,
      ),
      build: (context) {
        return pw.Column(children: [
          pw.Row(
            children: [
              pw.Image(
                pw.MemoryImage(uint8list),
                width: 75,
                height: 75,
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'EFB Handover Log',
                  style: pw.TextStyle(
                    fontSize: 23,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'xxxxxx',
              style: pw.TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: _buildHeaderCell('EFB Device', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device No 1', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Charger No', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('IOS Version', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 25.0,
                    child: _buildHeaderCell('EFB Software', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Flysmart Version', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('LIDO Version', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Docunet Version', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device Condition', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 35.0,
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text(
                      'It is confirmed that all IAA Operation Manual in this EFB are updated and EFB device in good condition',
                      style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    pw.Text('OCC ON DUTY'),
                    pw.SizedBox(height: 10.0),
                    pw.Text('xxxx'),
                  ],
                ),
              ),
              pw.Spacer(flex: 1),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    pw.Text('Receive Device 1 By'),
                    pw.SizedBox(height: 10.0),
                    pw.Text('xxxx'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 180),
          pw.Column(
            children: [footer],
          ),
        ]);
      },
    ),
  );

  final pdfBytes = await pdf.save();
  await file.writeAsBytes(pdfBytes);

  OpenFile.open(file.path);
}

pw.Widget _buildHeaderCell(String text, pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

pw.Widget _buildHeaderCellLeft(String text, pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

pw.Widget _buildHeaderCellRight(String text, pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
      ),
    ),
  );
}
