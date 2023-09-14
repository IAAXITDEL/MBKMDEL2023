import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmReturnOtherPilotView extends StatelessWidget {
  final String deviceName;
  final String deviceId;

  ConfirmReturnOtherPilotView({
    required this.deviceName,
    required this.deviceId,
  });

  // Function to update status to 'in-use-pilot' in Firestore
  void updateStatusToInUsePilot(String deviceId) {
    FirebaseFirestore.instance.collection('pilot-device-1').doc(deviceId).update({
      'status-device-1': 'in-use-pilot',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device Name: $deviceName'),
            Text('Device ID: $deviceId'),
            ElevatedButton(
              onPressed: () {
                // Call the function to update status to 'in-use-pilot'
                updateStatusToInUsePilot(deviceId);

                // Return to the previous page
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
