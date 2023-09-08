import 'package:flutter/cupertino.dart';

import '../theme.dart';

class RedTitleText extends StatelessWidget {
  final String text;
  final double size;
  const RedTitleText({Key? key, required this.text, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(
        fontSize: size ,
        fontWeight: FontWeight.w600,
        color: TsOneColor.primary,
        fontFamily: 'Poppins',
        decorationColor: TsOneColor.primary,
      ),
    );
  }
}

class BlackTitleText extends StatelessWidget {
  final String text;
  final double size;
  const BlackTitleText({Key? key, required this.text, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        decorationColor: TsOneColor.primary,
      ),
    );
  }
}
