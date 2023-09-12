import 'package:flutter/cupertino.dart';

import '../presentation/theme.dart';

class EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Image.asset('assets/images/nothing_found.png'),
            SizedBox(
              height: 20,
            ),
            Text(
              "Empty",
              style: tsOneTextTheme.headlineMedium,
            ),
            Center(
              child: Text(
                "You have no list ",
                style: tsOneTextTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
