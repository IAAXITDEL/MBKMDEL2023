import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackDetailPage extends StatelessWidget {
  final String feedbackId;

  FeedbackDetailPage({required this.feedbackId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('feedback-device')
            .doc(feedbackId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Feedback data not found'));
          }

          // Ambil data feedback dari Firestore
          final feedbackData = snapshot.data!.data() as Map<String, dynamic>;

          // Tampilkan data sesuai yang Anda butuhkan, misalnya, field 1-sector
          final sectorData = feedbackData['1-sector'];
          final q1 = feedbackData['q1'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1-Sector: $sectorData'),
                Text('1-Sector: $q1'),
                // Tampilkan data lainnya sesuai kebutuhan
              ],
            ),
          );
        },
      ),
    );
  }
}
