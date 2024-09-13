import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'complaint_history.dart';

class TrackComplaint extends StatefulWidget {
  @override
  State<TrackComplaint> createState() => _TrackComplaintState();
}

class _TrackComplaintState extends State<TrackComplaint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class TrackComplaintPage extends StatelessWidget {
  final String ticketNumber;
  final ComplaintData complaintData;

  const TrackComplaintPage({
    Key? key,
    required this.ticketNumber,
    required this.complaintData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Track Complaint', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  complaintData.imageUrl.isNotEmpty
                      ? Image.network(
                    complaintData.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 50),
                  )
                      : Icon(Icons.image_not_supported, size: 50),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaintData.category.isNotEmpty
                              ? complaintData.category
                              : 'No Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ticket no. ${complaintData.ticketNo.substring(0, 4)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          complaintData.description.isNotEmpty
                              ? complaintData.description
                              : 'No Description Available',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Timeline Section (dynamically fetched from admin progress notes)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('complaints')
                  .doc(complaintData.id)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return Text('No timeline data available or an error occurred.');
                }

                var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                var progressNotes = data['adminProgressNotes'] as List<dynamic>? ?? [];

                if (progressNotes.isEmpty) {
                  return Text('No progress notes available.');
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: progressNotes.length,
                    itemBuilder: (context, index) {
                      var note = progressNotes[index] as Map<String, dynamic>;
                      return TimelineTile(
                        title: note['status'] ?? 'Unknown Status',
                        date: '', // No date as requested
                        description: note['note'] ?? 'No additional notes',
                        isCompleted: note['status'] == 'Resolved',
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 1,
                  color: Colors.grey,
                ),
              ),
            ),
            // View details button
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 75.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle view details action
                  },
                  child: Text('View Details', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final bool isCompleted;

  const TimelineTile({
    required this.title,
    required this.date,
    required this.description,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            Container(
              width: 2,
              height: 65,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(date.isNotEmpty ? date : '', style: TextStyle(color: Colors.grey)),
              Text(description),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
