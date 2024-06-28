import 'package:flutter/material.dart';

class ReviewDetailsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              'Very disappointing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 5),
                Text('5 mins ago'),
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
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hom bdr. Pathak', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Phalewas'),
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
  }
}
