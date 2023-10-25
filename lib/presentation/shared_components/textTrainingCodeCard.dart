import 'package:pdf/widgets.dart' as pw;

class TextTrainingCodeCard extends pw.StatelessWidget {
  final String text;

  TextTrainingCodeCard({required this.text});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
        height: 16,
        child: pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.left,
          ),
        ));
  }
}
