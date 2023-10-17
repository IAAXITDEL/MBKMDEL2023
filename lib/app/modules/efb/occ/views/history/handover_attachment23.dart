import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../../../occ/views/history/detail_history_device_view.dart';
import 'package:http/http.dart' as http;


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

Future<void> generateLogPdfDevice23({
  String? userName,
  String? userRank,
  String? userID,
  String? occAccept,
  String? occGiven,
  String? deviceNo2,
  String? iosVer2,
  String? flySmart2,
  String? lido2,
  String? docunet2,
  String? deviceCondition2,
  String? deviceNo3,
  String? iosVer3,
  String? flySmart3,
  String? lido3,
  String? docunet3,
  String? deviceCondition3,
  String? ttdUser,
  String? ttdOCC,
  Timestamp? loan,
  String? statusdevice,
  String? handoverName,
  String? handoverID,
  String? ttdOtherCrew,
}) async {
  final pdf = pw.Document();

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/log_device2&3.pdf");

  final ByteData logo =
      await rootBundle.load('assets/images/airasia_logo_circle.png');
  final Uint8List uint8list = logo.buffer.asUint8List();

  final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  pw.Widget signatureImageWidget;
  if (ttdUser != null) {
    try {
      final imageBytes = await fetchImage(ttdUser);
      final image = pw.MemoryImage(imageBytes);
      signatureImageWidget = pw.Image(image);
    } catch (e) {
      print('Failed to load signature image: $e');
      signatureImageWidget = pw.Center(child: pw.Text('Failed to load signature image', style: pw.TextStyle(fontSize: 8)));
    }
  } else {
    signatureImageWidget = pw.Center(child: pw.Text('No signature available', style: pw.TextStyle(fontSize: 8)));
  }

  pw.Widget signatureImageOCCWidget;
  if (ttdOCC != null) {
    try {
      final imageBytes = await fetchImage(ttdOCC);
      final image = pw.MemoryImage(imageBytes);
      signatureImageOCCWidget = pw.Image(image);
    } catch (e) {
      print('Failed to load signature image: $e');
      signatureImageOCCWidget = pw.Center(child: pw.Text('Failed to load occ signature image', style: pw.TextStyle(fontSize: 8)));
    }
  } else {
    signatureImageOCCWidget = pw.Center(child: pw.Text('No signature available', style: pw.TextStyle(fontSize: 8)));
  }

  pw.Widget signatureImageOtherCrewWidget;
  if (ttdOtherCrew != null) {
    try {
      final imageBytes = await fetchImage(ttdOtherCrew);
      final image = pw.MemoryImage(imageBytes);
      signatureImageOtherCrewWidget = pw.Image(image);
    } catch (e) {
      print('Failed to load signature image: $e');
      signatureImageOtherCrewWidget = pw.Center(child: pw.Text('Failed to load other crew signature image', style: pw.TextStyle(fontSize: 8)));
    }
  } else {
    signatureImageOtherCrewWidget = pw.Center(child: pw.Text('No signature available', style: pw.TextStyle(fontSize: 8)));
  }

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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Align(
                child: pw.Text(
                  '2nd & 3rd Device',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Align(
                child: pw.Text(
                  _formatTimestamp(loan),
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
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
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device No 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$deviceNo2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device No 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$deviceNo3', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Charger No 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('xxxx', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Charger No 3', context),
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
                    child: _buildHeaderCellLeft('IOS Version 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$iosVer2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('IOS Version 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$iosVer3', context),
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
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Flysmart Version 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$flySmart2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Flysmart Version 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$flySmart3', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('LIDO Version 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$lido2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('LIDO Version 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$lido3', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Docunet Version 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$docunet2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Docunet Version 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$docunet3', context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device Condition 2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$deviceCondition2', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellLeft('Device Condition 3', context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: _buildHeaderCellRight('$deviceCondition3', context),
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

          //Handover to other crew
          if ('$statusdevice' == 'handover-to-other-crew')
            pw.SizedBox(height: 10.0),
          if ('$statusdevice' == 'handover-to-other-crew')
            pw.Table(
              tableWidth: pw.TableWidth.min,
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(4),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCell('Handover Details', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCell('Name', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCell('ID', context),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellRight('Handover From', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellRight('$userName', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellRight('$userID', context),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellLeft('Handover To', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellLeft('$handoverName', context),
                    ),
                    pw.Container(
                      height: 20.0,
                      child: _buildHeaderCellLeft('$handoverID', context),
                    ),
                  ],
                ),
              ],
            ),

          pw.SizedBox(height: 40),

          //handover to other crew
          if ('$statusdevice' == 'handover-to-other-crew')
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    children: [
                      pw.Text('1st Crew on Duty'),
                      pw.SizedBox(height: 5.0),
                      pw.Text('Device No 1 Sign'),
                      pw.SizedBox(height: 5.0),
                      pw.Container(
                        child: signatureImageWidget,
                        width: 150,
                        height: 90,
                      ),
                      pw.SizedBox(height: 5.0),
                      pw.Text(
                        '$userName',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    children: [
                      pw.Text('2st Crew on Duty'),
                      pw.SizedBox(height: 5.0),
                      pw.Text('Device No 2 Sign'),
                      pw.Container(
                        child: signatureImageOtherCrewWidget,
                        width: 150,
                        height: 90,
                      ),
                      pw.Text('ttd image'),
                      pw.SizedBox(height: 5.0),
                      pw.Text(
                        '$handoverName',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),


          if ('$statusdevice' == 'Done')
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    children: [
                      pw.Text('OCC Accepted Device'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    children: [
                      pw.Text('Receive Device 1 By'),

                    ],
                  ),
                ),
              ],
            ),
          if ('$statusdevice' == 'Done')
          pw.Row(
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 5.0),
                    pw.Container(
                      child: signatureImageOCCWidget,
                      width: 150,
                      height: 90,
                    ),
                    pw.SizedBox(height: 5.0),
                    pw.Text('$occAccept'),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 5.0),
                    pw.Container(
                      child: signatureImageWidget,
                      width: 150,
                      height: 90,
                    ),
                    pw.SizedBox(height: 5.0),
                    pw.Text('$userName'),
                    pw.SizedBox(height: 2.0),
                    pw.Text('$userRank'),
                  ],
                ),
              ),
            ],
          ),

          if ('$statusdevice' == 'handover-to-other-crew')
            pw.SizedBox(height: 50),
          if ('$statusdevice' == 'handover-to-other-crew')
            pw.Column(
              children: [footer],
            ),

          if ('$statusdevice' == 'Done') pw.SizedBox(height: 120),
          if ('$statusdevice' == 'Done')
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



