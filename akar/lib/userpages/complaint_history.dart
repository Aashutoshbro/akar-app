import 'package:flutter/material.dart';

class ComplaintHistory extends StatefulWidget {
  final Function(int) onPageChanged;


  const ComplaintHistory({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  State<ComplaintHistory> createState() => _ComplaintHistoryState();
}

class _ComplaintHistoryState extends State<ComplaintHistory> {
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
          'Complaint History',
          style: TextStyle(
            color: Colors.white, // Adjust text color for contrast
          ),
        ),
        backgroundColor: Colors.deepPurple, // Dark purple background for the entire app bar
      ),
      body: ListView(
        children: [
          ComplaintCard(
            status: 'In Progress',
            ticketNo: '#214',
            category: 'Plumbing',
            description: 'Water tap and sink pipe leakage, needs urgent work by plumber.',
            imageUrl: 'https://via.placeholder.com/150',
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: Text('WITHDRAW'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('TRACK'),
              ),
            ],
          ),
          ComplaintCard(
            status: 'In Progress',
            ticketNo: '#214',
            category: 'Plumbing',
            description: 'Water tap and sink pipe leakage, needs urgent work by plumber.',
            imageUrl: 'https://via.placeholder.com/150',
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: Text('WITHDRAW'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('TRACK'),
              ),
            ],
          ),
          ComplaintCard(
            status: 'Resolved',
            ticketNo: '#207',
            category: 'Electrical',
            description: 'Switch board near the kitchen not working from the last 2 days.',
            imageUrl: 'https://via.placeholder.com/150',
            resolvedBy: 'Ghoreesh Rana',
            resolvedDate: '25 Feb, 3:45 PM',
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: Text('View Details'),
              ),
            ],
            rating: 3,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add complaint action
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
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
