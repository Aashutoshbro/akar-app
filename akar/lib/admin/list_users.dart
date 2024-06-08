import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String name;
  final String contact;
  final String email;
  final String? profileImageURL;

  User({
    required this.name,
    required this.contact,
    required this.email,
    this.profileImageURL,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>; // Ensuring the data is treated as a Map
    return User(
      name: data['name'],
      contact: data['contact'],
      email: data['email'],
      profileImageURL: data.containsKey('profileImageURL') ? data['profileImageURL'] : null,
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

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: user.profileImageURL != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageURL!),
          radius: 25,
        )
            : CircleAvatar(
          child: Icon(Icons.person),
          radius: 25,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(user.contact),
            Text(user.email),
          ],
        ),
        trailing: Icon(
          Icons.edit,
          color: Colors.deepPurple,
        ),
        isThreeLine: true,
      ),
    );
  }
}
