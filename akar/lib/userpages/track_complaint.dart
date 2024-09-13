import 'package:flutter/material.dart';

class TrackComplaintPage extends StatelessWidget {
  final String ticketNumber;

  const TrackComplaintPage({Key? key, required this.ticketNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Complaint'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text('Tracking complaint with Ticket #: $ticketNumber'),
      ),
    );
  }
}
