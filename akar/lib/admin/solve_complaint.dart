import 'package:flutter/material.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String name = 'Rajeev Paudel';
  final String contact = 'Contact: 9869058801';
  final String cid = 'Cid: 88-44-1080';
  final String ticketNumber = 'Ticket Number: rvh01';
  final String complaintDetails= "There is a large pothole on the main road.";
  final String complaintType = 'Overflowing home water tank';
  final String category = 'Water Supply';
  final String status = 'Raised';
  final String date = '28 May 2024 08:12 AM';
  final String landmark = 'Near Community Hall';
  final String location = 'Kathmandu';
  final String streetName = 'Some Street';
  final String wardNumber = 'Ward No. 5';

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
        title: Text(name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
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
                          contact,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          cid,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          ticketNumber,
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
                        Text('$date', style: TextStyle(fontSize: 16)),
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
                          'Street Name',
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
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            // Implement the action for the button
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 16,),
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
