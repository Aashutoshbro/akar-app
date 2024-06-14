import 'package:akar/admin/set_status.dart';
import 'package:akar/admin/view_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;

  ComplaintDetailPage({required this.complaintId});

  String formatTimestamp(Timestamp timestamp) {
    var dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y \'at\' h:mm:ss a z').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Complaint Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('complaints').doc(complaintId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data found'));
          }

          var complaintData = snapshot.data!;
          var name = complaintData['fullName'];
          var phoneNumber = complaintData['phoneNumber'];
          var citizenshipNumber = complaintData['citizenshipNumber'];
          var ticketNumber = complaintData['ticketNumber'];
          var complaintDetails = complaintData['complaintDetails'];
          var complaintType = complaintData['complaintType'];
          var category = complaintData['category'];
          var status = complaintData['status'];
          var timestamp = complaintData['timestamp'] as Timestamp;
          var formattedDate = formatTimestamp(timestamp);
          var landmark = complaintData['landmark'];
          var location = complaintData['location'];
          var streetName = complaintData['streetName'];
          var wardNumber = complaintData['wardNumber'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Contact: $phoneNumber',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Cid: $citizenshipNumber',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Ticket: $ticketNumber',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Complaint Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Description:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$complaintDetails', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Complaint Type:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$complaintType', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Category:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$category', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Status:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$status', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Date:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$formattedDate', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                          ],
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ImageCarousel(complaintId: complaintId)),
                              );
                              // Add your onPressed action here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple, // Background color
                            ),
                            child: Text('View Image', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Location Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Landmark:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$landmark', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Location:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$location', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Street Name:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$streetName', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text(
                              'Ward Number:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('$wardNumber', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                          ],
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your onPressed action here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple, // Background color
                            ),
                            child: Text('Track Location', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80), // Provide space for sticky button
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,

        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SetStatusPage(complaintId: complaintId);
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Set Status',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),


      ),
    );
  }
}
