import 'package:flutter/cupertino.dart';

import '../theme.dart';

class RedTitleText extends StatelessWidget {
  final String text;
  const RedTitleText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
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
  const BlackTitleText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        decorationColor: TsOneColor.primary,
      ),
    );
  }
}
