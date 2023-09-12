import 'package:flutter/cupertino.dart';

import '../presentation/theme.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset('assets/images/nothing_found.png'),
            const SizedBox(
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
  }
}
