import 'package:pdf/widgets.dart' as pw;

class NormalTextFieldPdf extends pw.StatelessWidget {
  final String title;

  NormalTextFieldPdf({required this.title});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 9))
    );
  }
}
