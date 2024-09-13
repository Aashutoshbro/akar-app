<<<<<<< HEAD
import 'package:akar/userpages/track_complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth to get current user
=======
import 'package:cloud_firestore/cloud_firestore.dart';
>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
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
<<<<<<< HEAD
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

=======
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print("Received userID: ${widget.userID}");
  }

>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
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
<<<<<<< HEAD
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder(
        future: _getComplaintHistory(),
        builder: (context, AsyncSnapshot<List<ComplaintData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching complaints.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No complaints found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var complaint = snapshot.data![index];
                return ComplaintCard(
                  status: complaint.status,
                  ticketNo: complaint.ticketNo,
                  category: complaint.category,
                  description: complaint.description,
                  imageUrl: complaint.imageUrl,
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        _showWithdrawConfirmation(context, complaint);
                      },
                      child: Text('WITHDRAW'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrackComplaintPage(complaintData: complaint

                              )),
                        );
                      },
                      child: Text('TRACK'),
                    ),
                  ],
                );
              },
            );
          }
=======
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
>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
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

<<<<<<< HEAD
  Future<List<ComplaintData>> _getComplaintHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('complaints')
        .where('userID', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      return ComplaintData.fromFirestore(doc);
    }).toList();
  }

  Future<void> _showWithdrawConfirmation(BuildContext context, ComplaintData complaint) async {
    if (complaint.status != 'In Progress') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Withdrawal is not possible for resolved complaints.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Withdraw Complaint'),
          content: Text('Are you sure you want to withdraw this complaint?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      _withdrawComplaint(complaint);
    }
  }

  Future<void> _withdrawComplaint(ComplaintData complaint) async {
    try {
      await _firestore.collection('complaints').doc(complaint.id).update({
        'status': 'Withdrawn',
        'withdrawnAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint successfully withdrawn.'),
        backgroundColor: Colors.green,
      ));

      setState(() {}); // Refresh the list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to withdraw the complaint. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
class ComplaintData {
  final String id; // Firestore document ID for updating the status
  final String status;
  final String ticketNo;
  final String category;
  final String description;
  final String imageUrl;

  ComplaintData({
    required this.id,  // Pass document ID from Firestore
    required this.status,
    required this.ticketNo,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  factory ComplaintData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ComplaintData(
      id: doc.id,  // Store document ID to use for withdrawal update
      status: data['status'] ?? 'Unknown Status',
      ticketNo: data['ticketNumber'] ?? 'Unknown Ticket No',
      category: data['category'] ?? 'Unknown Category',
      description: data['complaintDetails'] ?? 'No description available',
      imageUrl: (data['images'] != null && data['images'].isNotEmpty)
          ? data['images'][0]
          : 'https://via.placeholder.com/150', // Fallback image
    );
  }
}
=======

>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
class ComplaintCard extends StatelessWidget {
  final String status;
  final String ticketNo;
  final String category;
  final String description;
  final String imageUrl;
  final List<Widget> actions;

  ComplaintCard({
    required this.status,
    required this.ticketNo,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.actions,
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
                  status == 'Complaint Resolved' ? Icons.check_circle : Icons.timelapse,
                  color: status == 'Complaint Resolved' ? Colors.green : Colors.blue,
                ),
                SizedBox(width: 10),
                Text(
                  status,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text('Ticket no. ${ticketNo.substring(0, 4)}'), // Limit ticket number
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
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 50);
                  },
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
<<<<<<< HEAD
=======
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
>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
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
