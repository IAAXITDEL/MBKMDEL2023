import 'package:flutter/material.dart';

import '../presentation/theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: TsOneColor.primary,
        backgroundColor: Colors.red[200],
      ),
    );
  }
}
