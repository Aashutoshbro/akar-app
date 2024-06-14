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

class ComplaintsHomePage extends StatefulWidget {
  @override
  _ComplaintsHomePageState createState() => _ComplaintsHomePageState();
}

class _ComplaintsHomePageState extends State<ComplaintsHomePage> {
  String _selectedFilter = 'All';

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
              FilterChip(
                label: Text('All'),
                selected: _selectedFilter == 'All',
                onSelected: (bool value) {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
              ),
              FilterChip(
                label: Text('Pending'),
                selected: _selectedFilter == 'Pending',
                onSelected: (bool value) {
                  setState(() {
                    _selectedFilter = 'Pending';
                  });
                },
              ),
              FilterChip(
                label: Text('Resolved'),
                selected: _selectedFilter == 'Resolved',
                onSelected: (bool value) {
                  setState(() {
                    _selectedFilter = 'Resolved';
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var complaints = snapshot.data!.docs;

              // Filter complaints based on the selected filter and check for the 'status' field
              if (_selectedFilter == 'Pending') {
                complaints = complaints.where((doc) => doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('status') && doc['status'] != 'Complaint Resolved').toList();
              } else if (_selectedFilter == 'Resolved') {
                complaints = complaints.where((doc) => doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('status') && doc['status'] == 'Complaint Resolved').toList();
              }

              var urgentComplaints = complaints.where((doc) => (doc.data() as Map<String, dynamic>)['natureOfComplaint'] == 'Urgent').toList();
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
                        var complaint = complaints[index].data() as Map<String, dynamic>;
                        return ComplaintCard(
                          name: complaint['fullName'],
                          time: complaint['timestamp'].toDate().toString(),
                          complaintId: complaint['ticketNumber'],
                          complaintText: complaint['complaintDetails'],
                          streetName: complaint['streetName'],
                          wardNumber: complaint['wardNumber'],
                          urgency: complaint['natureOfComplaint'],
                          status: complaint.containsKey('status') ? complaint['status'] : 'Unknown',  // Check for status
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
  final String status;

  ComplaintCard({
    required this.name,
    required this.time,
    required this.complaintId,
    required this.complaintText,
    required this.streetName,
    required this.wardNumber,
    required this.urgency,
    required this.status,  // Include status
  });

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    // Determine the icon, color, and text based on the status
    if (status == 'Complaint Resolved') {
      statusIcon = Icons.check_circle_outline;
      statusColor = Colors.green;
      statusText = 'Resolved';
    } else {
      statusIcon = Icons.hourglass_empty;
      statusColor = Colors.orange;
      statusText = 'In Progress';
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.purple),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor),
                      SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(name),
                ],
              ),
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
