import 'package:pdf/widgets.dart' as pw;

class RemarkTextCard extends pw.StatelessWidget {
  final String text;

  RemarkTextCard({required this.text});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 8))
    );
  }
}
