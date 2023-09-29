import 'package:pdf/widgets.dart' as pw;

class TextFieldPdf extends pw.StatelessWidget {
  final String title;

  TextFieldPdf({required this.title});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.left,),
    );
  }
}