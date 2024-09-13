import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:akar/userpages/track_complaint.dart';

class ComplaintHistory extends StatefulWidget {
  final Function(int) onPageChanged;
  final String userID;

  const ComplaintHistory({Key? key, required this.onPageChanged, required this.userID})
      : super(key: key);

  @override
  State<ComplaintHistory> createState() => _ComplaintHistoryState();
}

class _ComplaintHistoryState extends State<ComplaintHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print("Received userID: ${widget.userID}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complaint History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .where('userId', isEqualTo: widget.userID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No complaints found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ComplaintCard(
                status: data['status'] ?? 'Unknown',
                ticketNo: data['ticketNumber'] ?? 'Unknown',
                category: data['category'] ?? 'Uncategorized',
                description: data['complaintDetails'] ?? 'No description provided',
                imageUrl: (data['images'] as List<dynamic>?)?.first ?? 'https://via.placeholder.com/150',
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Implement Withdraw action if needed
                    },
                    child: Text(data['status'] == 'Resolved' ? 'View Details' : 'WITHDRAW'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackComplaintPage(
                            ticketNumber: data['ticketNumber'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Text('TRACK'),
                  ),
                ],
                resolvedBy: data['status'] == 'Resolved' ? 'Some User' : '',
                resolvedDate: data['status'] == 'Resolved' ? '25 Feb, 3:45 PM' : '',
                rating: data['status'] == 'Resolved' ? 3 : 0,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add complaint action
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.edit, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      ),
    );
  }
}


class ComplaintCard extends StatelessWidget {
  final String status;
  final String ticketNo;
  final String category;
  final String description;
  final String imageUrl;
  final String resolvedBy;
  final String resolvedDate;
  final List<Widget> actions;
  final int rating;

  ComplaintCard({
    required this.status,
    required this.ticketNo,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.actions,
    this.resolvedBy = '',
    this.resolvedDate = '',
    this.rating = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status == 'Resolved' ? Icons.check_circle : Icons.timelapse,
                  color: status == 'Resolved' ? Colors.green : Colors.blue,
                ),
                SizedBox(width: 10),
                Text(
                  status,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text('Ticket no. $ticketNo'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
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
                        category,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(description),
                    ],
                  ),
                ),
              ],
            ),
            if (resolvedBy.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Your complaint was successfully resolved by $resolvedBy on $resolvedDate',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (rating > 0)
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
