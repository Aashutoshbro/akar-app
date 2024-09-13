import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewDetailsModal extends StatelessWidget {
  final String userId;

  ReviewDetailsModal({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('feedback').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.data!.exists) {
          return Center(child: Text('Review not found.'));
        }

        final reviewData = snapshot.data!.data() as Map<String, dynamic>?;
        if (reviewData == null) {
          return Center(child: Text('Review data is null.'));
        }

        final comment = reviewData['comments'] ?? 'No comment provided';
        final rating = reviewData['rating'] ?? 0;
        final timestamp = reviewData['timestamp'] as Timestamp? ?? Timestamp.now();
        final userRef = reviewData['userId'];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userRef).get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (!userSnapshot.data!.exists) {
              return Center(child: Text('User not found.'));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              return Center(child: Text('User data is null.'));
            }

            final name = userData['name'] ?? 'No name provided';
            final homeAddress = userData['homeAddress'] ?? 'No address provided';
            final profileImageURL = userData['profileImageURL'] ?? 'https://via.placeholder.com/150';

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small line above "Review Details"
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // "Review Details" text and close icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the text
                      children: [
                        Spacer(), // Push the text to the center
                        Text(
                          'Review Details',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(), // Push the text to the center
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      comment,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 5),
                        Text(timestamp.toDate().toString()),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "This app is a prime example of how not to design for performance. It's evident that the developers didn't invest enough time and effort in optimizing it. It's sluggish, clunky, and prone to crashes. I can't rely on it for important tasks, as it frequently fails to deliver. I've tried updating, reinstalling, and even resetting my device, but nothing seems to improve its performance. It's a major disappointment.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profileImageURL),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(homeAddress),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Reply for this message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('00/80', style: TextStyle(color: Colors.grey)),
                        ElevatedButton(
                          onPressed: () {
                            // Add your onPressed action here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
