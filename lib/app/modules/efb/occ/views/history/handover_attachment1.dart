import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../../../occ/views/history/detail_history_device_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'No Data';

  DateTime dateTime = timestamp.toDate();
  // Format the date and time as desired, e.g., 'dd/MM/yyyy HH:mm:ss'
  String formattedDateTime =
      '${dateTime.day}/${dateTime.month}/${dateTime.year}'
      ' at '
      '${dateTime.hour}:${dateTime.minute}';
  return formattedDateTime;
}

Future<void> generateLogPdfDevice1({
  String? userName,
  String? userRank,
  String? occAccept,
  String? occGiven,
  String? deviceNo,
  String? iosVer,
  String? flySmart,
  String? lido,
  String? docunet,
  String? deviceCondition,
  String? ttdUser,
  Timestamp? loan,
}) async {
  final pdf = pw.Document();

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/log_device1.pdf");

  final ByteData logo =
      await rootBundle.load('assets/images/airasia_logo_circle.png');
  final Uint8List uint8list = logo.buffer.asUint8List();

  final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  final Uint8List imagettdUser = await fetchImage('$ttdUser');

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
              _formatTimestamp(loan),
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
                    child: _buildHeaderCellRight('$deviceNo', context),
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
                    child: _buildHeaderCellRight('$iosVer', context),
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
                    child: _buildHeaderCellRight('$flySmart', context),
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
                    child: _buildHeaderCellRight('$lido', context),
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
                    child: _buildHeaderCellRight('$docunet', context),
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
                    child: _buildHeaderCellRight('$deviceCondition', context),
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
                    pw.Text('OCC Given Device'),
                    pw.SizedBox(height: 10.0),
                    pw.Text('$occGiven'),
                  ],
                ),
              ),
              pw.Spacer(flex: 1),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    pw.Text('OCC Accepted Device'),
                    pw.SizedBox(height: 10.0),
                    pw.Text('$occAccept'),
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
                    //pw.Image(),
                    pw.SizedBox(height: 5.0),
                    pw.Text('$userRank'),
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

Future<Uint8List> fetchImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}
