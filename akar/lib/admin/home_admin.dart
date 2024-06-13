import 'package:akar/admin/solve_complaint.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Complaint',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ComplaintsHomePage(),
    );
  }
}

class ComplaintsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.purple),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Namaste', style: TextStyle(fontSize: 16)),
                  Text('Admin',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Complaints',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterChip(label: Text('All'), onSelected: (bool value) {}),
              FilterChip(label: Text('Urgent'), onSelected: (bool value) {}),
              FilterChip(label: Text('Medium'), onSelected: (bool value) {}),
              FilterChip(label: Text('Low'), onSelected: (bool value) {}),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('complaints')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var complaints = snapshot.data!.docs;
              var urgentComplaints = complaints.where((
                  doc) => doc['natureOfComplaint'] == 'Urgent').toList();
              var urgentCount = urgentComplaints.length;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'We found "$urgentCount Urgent complaints", focus on solving problem based on priority',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        var complaint = complaints[index];
                        return ComplaintCard(
                          name: complaint['fullName'],
                          time: complaint['timestamp'].toDate().toString(),
                          complaintId: complaint['ticketNumber'],
                          complaintText: complaint['complaintDetails'],
                          streetName: complaint['streetName'],
                          wardNumber: complaint['wardNumber'],
                          urgency: complaint['natureOfComplaint'],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String name;
  final String time;
  final String complaintId;
  final String complaintText;
  final String streetName;
  final String wardNumber;
  final String urgency;

  ComplaintCard({
    required this.name,
    required this.time,
    required this.complaintId,
    required this.complaintText,
    required this.streetName,
    required this.wardNumber,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.purple),
              ),
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time),
                  SizedBox(height: 4),
                  Text(
                    complaintText,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Street: $streetName',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ward: $wardNumber',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),

              trailing: IconButton(
                icon: Icon(Icons.visibility, color: Colors.purple),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComplaintDetailPage(complaintId: complaintId),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                urgency,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}