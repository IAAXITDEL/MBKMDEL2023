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

//EMPTY ATTENDANCE DATA
class EmptyScreenAttendanceData extends StatelessWidget {
  const EmptyScreenAttendanceData({super.key});

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
                "You have no attendance data",
                style: tsOneTextTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EMPTY PILOT DATA
class EmptyScreenPilotData extends StatelessWidget {
  const EmptyScreenPilotData({super.key});

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
                "You have no pilot data",
                style: tsOneTextTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//EMPTY FFEDBACK REQUIRED ->> PILOT HOMEPAGE
class EmptyScreenFeedbackRequired extends StatelessWidget {
  const EmptyScreenFeedbackRequired({super.key});

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
                "You have no feedback to fill in currently.",
                style: tsOneTextTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



