import 'package:flutter/cupertino.dart';

import '../presentation/theme.dart';

class EmptyScreenEFB extends StatelessWidget {
  const EmptyScreenEFB({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Wrap with SingleChildScrollView
      child: Center(
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
                "Hii There!",
                style: tsOneTextTheme.headlineMedium,
              ),
              Center(
                child: Text(
                  "Looks like the data is still empty :) ",
                  style: tsOneTextTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
