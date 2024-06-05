import 'package:flutter/material.dart';

class TrackComplaint extends StatefulWidget {
  @override
  State<TrackComplaint> createState() => _TrackComplaintState();
}

class _TrackComplaintState extends State<TrackComplaint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}

class TrackComplaintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
            color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Complaint',
          style: TextStyle(
            color: Colors.white, // Adjust text color for contrast
          ),
        ),
        backgroundColor: Colors.deepPurple, // Dark purple background for the entire app bar
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
                  Image.network(
                    'https://via.placeholder.com/150', // Replace with the actual image URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poth Holes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Ticket no. #214'),
                        Text(
                          'Huge Poth holes causing many accidents',
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

            // Timeline Section
            Text(
              'Complaint Resolved on Mon 19, 20',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  TimelineTile(
                    title: 'Complaint Raised',
                    date: 'Mon, 19 Oct 20',
                    description: 'Your complaint has been raised at 2:32 PM',
                    isCompleted: true,
                  ),
                  TimelineTile(
                    title: 'Task Assigned',
                    date: 'Mon, 19 Oct 20',
                    description: 'Admin has assigned the task to Ghoreesh Rana who will attend your complaint around 6 PM',
                    isCompleted: true,
                  ),
                  TimelineTile(
                    title: 'Staff on Site',
                    date: 'Mon, 19 Oct 20',
                    description: 'Staff started attending your complaint at 5:45 PM',
                    isCompleted: true,
                  ),
                  TimelineTile(
                    title: 'Complaint Resolved',
                    date: 'Mon, 19 Oct 20',
                    description: 'Complaint was successfully attended and resolved at 7:20 PM',
                    isCompleted: false,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10), // Add vertical padding here
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
                  height: 1,
                  color: Colors.grey, // Color of the horizontal line
                ),
              ),
            ),
            // view details
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 75.0), // Adjust this value to your preference
                child: ElevatedButton(
                  onPressed: () {
                    // Handle reopen complaint action
                  },
                  child: Text(
                    'View Details',
                    style: TextStyle(fontSize: 16),
                  ),
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

  TimelineTile({
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
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(date, style: TextStyle(color: Colors.grey)),
              Text(description),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}