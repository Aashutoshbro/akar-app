import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String name;
  final String contact;
  final String email;
  // final String avatarUrl;

  User({
    required this.name,
    required this.contact,
    required this.email,
    // required this.avatarUrl,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      name: doc['name'],
      contact: doc['contact'],
      email: doc['email'],
      // avatarUrl: doc['avatarUrl'],
    );
  }
}

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _fetchUsers();
  }

  void _fetchUsers() async {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      List<User> users = snapshot.docs.map((doc) => User.fromDocument(doc)).toList();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    });
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
      user.name.toLowerCase().contains(query) ||
          user.contact.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back icon color to white
        ),
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Users',
          style: TextStyle(
            color: Colors.white, // Adjust text color for contrast
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.add,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     // Handle add user action
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 10),
            TabBarViewWidget(),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  return UserCard(user: _filteredUsers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabBarViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // TabBar(
          //   isScrollable: true,
          //   labelColor: Colors.black,
          //   unselectedLabelColor: Colors.grey,
          //   indicatorColor: Colors.blue,
          //   tabs: [
          //     Tab(text: 'All'),
          //     Tab(text: 'Dispatchers'),
          //     Tab(text: 'Administrators'),
          //     Tab(text: 'Technicians'),
          //   ],
          // ),
          SizedBox(
            height: 0, // Placeholder for TabBarView
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        // leading: SvgPicture.network(
        //   user.avatarUrl,
        //   width: 50,
        //   height: 50,
        // ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(user.contact),
            Text(user.email),
          ],
        ),
        trailing: Icon(Icons.edit,
        color: Colors.deepPurple,
        ),
        isThreeLine: true,
      ),
    );
  }
}
