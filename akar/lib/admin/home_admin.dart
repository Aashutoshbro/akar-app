import 'package:flutter/material.dart';

import 'list_users.dart';
class HomeAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaints App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ComplaintsHomePage(),
    );
  }
}

class ComplaintsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersPage()),
              );
            },
          )
        ],
      ),
      body: Column(
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
                    Text('Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'We found "10 Urgent complaints", so please try to focus urgent complaints first.',
              style: TextStyle(color: Colors.red),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ComplaintCard(
                  name: 'Rajeev Paudel',
                  time: '28 May 2024 08:12 AM',
                  complaintId: '120',
                  complaintText: 'Regarding overflowing home water tank',
                  urgency: 'Urgent',
                ),
                ComplaintCard(
                  name: 'Kishan Pathak',
                  time: '26 May 2024 10:30 AM',
                  complaintId: '110',
                  complaintText: 'Issue about low power supply to my home',
                  urgency: 'Urgent',
                ),
                ComplaintCard(
                  name: 'Aashutosh Sapkota',
                  time: '20 May 2024 08:10 PM',
                  complaintId: '100',
                  complaintText: 'Drainage Leakage',
                  urgency: 'Urgent',
                ),
                ComplaintCard(
                  name: 'Abhishek Sharma',
                  time: '27 May 2024 7:30 AM',
                  complaintId: '113',
                  complaintText: 'Street light pole current leakage',
                  urgency: 'Urgent',
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String name;
  final String time;
  final String complaintId;
  final String complaintText;
  final String urgency;

  ComplaintCard({
    required this.name,
    required this.time,
    required this.complaintId,
    required this.complaintText,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
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
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              urgency,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 4),
            Icon(Icons.phone, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
