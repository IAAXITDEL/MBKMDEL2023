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
  // Format the date and time as desired dd/MM/ss..
  String formattedDateTime = '${dateTime.day}/${dateTime.month}/${dateTime.year}'
      ' at '
      '${dateTime.hour}:${dateTime.minute}';
  return formattedDateTime;
}

// PDF FEEDBACK.
Future<void> generateFeedbackForm({
  Timestamp? date,
  String? q1,
  String? q2,
  String? q3,
  String? q4,
  String? q5,
  String? q6,
  String? q7,
  String? q8,
  String? q9,
  String? q10,
  String? q11,
  String? q12,
  String? q13,
  String? q14,
  String? q15,
  // String? q16,
  String? sector1,
  String? sector2,
  String? sector3,
  String? sector4,
  String? sector5,
  String? sector6,
  String? ifhigh,
  String? additionalComment,
  String? devicename1,
  String? devicename2,
  String? devicename3,
  String? userName,
  String? userRank,
  String? recNo,
  String? datedoc,
  String? page,
  String? footerLeft,
  String? footerRight,
}) async {
  final pdf = pw.Document();

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/feedback_form.pdf");

  final ByteData logo = await rootBundle.load('assets/images/airasia_logo_circle.png');
  final Uint8List uint8list = logo.buffer.asUint8List();

  final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  final footer = pw.Container(
    padding: const pw.EdgeInsets.all(5.0),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('$footerLeft'),
        ),
        pw.Spacer(),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('$footerRight'),
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
        marginBottom: 36.0,
      ),
      build: (context) {
        return pw.Column(children: [
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Image(
                          pw.MemoryImage(uint8list),
                          width: 65,
                          height: 65,
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 5),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'IAA EFB',
                            style: pw.TextStyle(
                              // font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'FEEDBACK FORM',
                            style: pw.TextStyle(
                              // font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          if (devicename2 == '-' && devicename3 == '-')
                            pw.Text(
                              '$devicename1',
                              style: pw.TextStyle(
                                // font: ttf,
                                fontSize: 12,
                              ),
                            ),
                          if (devicename1 == '-')
                            pw.Text(
                              '$devicename2 & $devicename3',
                              style: pw.TextStyle(
                                // font: ttf,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Rec. No.',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '$recNo',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Date',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '$datedoc',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Page',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                              pw.Text(
                                '$page',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          // pw.SizedBox(height: 4),
                          // pw.Row(
                          //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     pw.Text(
                          //       'Page',
                          //       style: pw.TextStyle(
                          //         font: ttf,
                          //         fontSize: 8,
                          //       ),
                          //     ),
                          //     pw.Text(
                          //       '1 of 1',
                          //       style: pw.TextStyle(
                          //         font: ttf,
                          //         fontSize: 8,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Dear Pilots, The following test must be conducted on the IPAD PRO 10.5',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 11,
              ),
            ),
          ),
          pw.Table(
            tableWidth: pw.TableWidth.min,
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: reguler("DATE", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler(_formatTimestamp(date), context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("RANK", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("$userRank", context),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 20.0,
                    child: reguler("Device No.", context),
                  ),
                  if (devicename2 == '-' || devicename2 == null)
                    pw.Container(
                      height: 20.0,
                      child: reguler("$devicename1", context),
                    ),
                  if (devicename1 == '-')
                    pw.Container(
                      height: 20.0,
                      child: reguler("$devicename2 & $devicename3", context),
                    ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("CREW NAME", context),
                  ),
                  pw.Container(
                    height: 20.0,
                    child: reguler("$userName", context),
                  ),
                ],
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
                    child: boldTitle('BATTERY INTEGRITY', context),
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
              1: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Column(children: [
                    reguler("Do you charge the device during your duty?\n" + "$q1", context),
                    bold("If charging the device is REQUIRED.", context),
                    pw.Column(children: [
                      reguler("1.  Flight Phase\n" + "     $q3", context),
                      reguler("2.  Charging duration\n" + "     $q4", context),
                    ])
                  ]),
                  pw.Column(children: [
                    reguler("Do you find any risk or concern on the cabling?\n" + "$q2", context),
                    bold("If charging the device is NOT REQUIRED.", context),
                    pw.Column(children: [
                      reguler("1.  Did you utilize ALL EFB software during your duty?\n" + "     $q5", context),
                      reguler("2.  Which software did you utilize the most?\n" + "     $q6", context),
                    ])
                  ]),
                ],
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
                    child: boldTitle('BATTERY LEVEL AFTER ENGINE SHUTDOWN (with or without charging)', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(2),
            6: pw.FlexColumnWidth(2),
          }, children: [
            pw.TableRow(
              children: [
                reguler("%", context),
                reguler("1st  " + "  $sector1", context),
                reguler("2nd  " + "  $sector2", context),
                reguler("3rd  " + "  $sector3", context),
                reguler("4th  " + "  $sector4", context),
                reguler("5th  " + "  $sector5", context),
                reguler("6th  " + "  $sector6", context),
              ],
            ),
          ]),
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
                    child: boldTitle('VIEWABLE SOFTWARE INTEGRITY', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
          }, children: [
            pw.TableRow(
              children: [
                pw.Column(children: [
                  reguler(
                    'Please observe the bracket and tick on your answer :\n' +
                        '\n' +
                        '  1.  Strong Mechanical Integrity Flight\n' +
                        "       $q7\n" +
                        '  2.  Easy to use\n' +
                        "       $q8\n" +
                        '  3.  Easy to detached during emergency, if required\n' +
                        "       $q8\n" +
                        '  4.  Obstruct emergency egress\n' +
                        "       $q10\n" +
                        '  5.  Bracket position obstruct Pilot vision\n' +
                        "       $q11 (If Yes, How severe did it obstruct your vision)?\n" +
                        "       $q12\n",
                    context,
                  ),
                ])
              ],
            ),
          ]),
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
                    child: boldTitle('EFB SOFTWARE INTEGRITY', context),
                  )
                ],
              ),
            ],
          ),
          pw.Table(tableWidth: pw.TableWidth.min, border: pw.TableBorder.all(), columnWidths: {
            0: pw.FlexColumnWidth(1),
          }, children: [
            pw.TableRow(
              children: [
                pw.Column(children: [
                  reguler(
                    '  1.  Airbus Flysmart (Performance)' +
                        "             $q13\n" +
                        '  2.  Lido (Navigation)' +
                        "                                   $q14\n" +
                        '  3.  Vistair Docunet (Library Document)' +
                        "      $q15\n",
                    context,
                  ),
                ])
              ],
            ),
          ]),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Additional comment on all observation : $additionalComment',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 8,
              ),
            ),
          ),
          pw.SizedBox(height: 20.0),
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
//child: _buildHeaderCellLeft('Handover To', context),

pw.Widget bold(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        // font: ttf,
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
    ),
  );
}

pw.Widget boldTitle(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        // font: ttf,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

pw.Widget reguler(String text, pw.Context context) {
  // final fontData = rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  // final ttf = pw.Font.ttf(fontData as ByteData);

  return pw.Container(
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.TableBorder.all(),
    ),
    padding: pw.EdgeInsets.all(5.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        //font: ttf,
        fontSize: 9,
      ),
    ),
  );
}
