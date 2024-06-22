import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PersonalInformationPage extends StatefulWidget {
  @override
  _PersonalInformationPageState createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      return doc.data() ?? {};
    } else {
      throw Exception('User not logged in');
    }
  }

  String? getStringValue(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is String) {
      return value;
    } else if (value is int || value is double || value is bool) {
      return value.toString();
    } else if (value is Timestamp) {
      final dateTime = value.toDate();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else {
      return 'Invalid data type';
    }
  }

  Widget buildShimmerPlaceholder() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildShimmerSectionTitle(),
          ...List.generate(3, (_) => buildShimmerDetailCard()),

          buildShimmerSectionTitle(),
          ...List.generate(3, (_) => buildShimmerDetailCard()),

          buildShimmerSectionTitle(),
          ...List.generate(3, (_) => buildShimmerDetailCard()),
        ],
      ),
    );
  }

  Widget buildShimmerSectionTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: 24.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // Adjust the value to control the curvature
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
      ),
    );
  }


  Widget buildShimmerDetailCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0), // Adjust the value to control the curvature
                ),

              ),
              SizedBox(height: 8.0),
              Container(
                width: 150.0,
                height: 16.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> editField(String field) async {
    String newValue = '';


    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(newValue);
              if (newValue.isNotEmpty && currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .update({field: newValue});

                setState(() {}); // Refresh the UI to show updated value
              }
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildShimmerPlaceholder();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No user data found'));
          }

          var userData = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: 'Personal Details'),
                  DetailCard(title: 'Full Name', value: getStringValue(userData['name']),isEditable: true, onEdit: () => editField('name'),),
                  DetailCard(title: 'Email', value: getStringValue(userData['email']),isEditable: true, onEdit: () => editField('email'),),
                  DetailCard(title: 'Contact', value: getStringValue(userData['contact']),isEditable: true, onEdit: () => editField('contact'),),
                  // Add more fields as necessary

                  SectionTitle(title: 'Address Details'),
                  DetailCard(title: 'Home Address', value: getStringValue(userData['homeAddress']), isEditable: true,onEdit: () => editField('homeAddress'),),
                  DetailCard(title: 'Zip/Postal', value: getStringValue(userData['postal_code']),isEditable: true,onEdit: () => editField('postal_code'),),
                  DetailCard(title: 'State', value: getStringValue(userData['state']),isEditable: true,onEdit: () => editField('state'),
                  ),
                  DetailCard(title: 'Home Number', value: getStringValue(userData['home_number']),isEditable: true, onEdit: () => editField('home_number'),),
                  // Add more fields as necessary

                  SectionTitle(title: 'Document Details'),
                  DetailCard(
                    title: 'Citizenship (Front)',
                    value: getStringValue(userData['idImageURL']),
                    isImage: true,
                    isEditable: false,// Pass a flag indicating this is an image
                    onEdit: () {
                      // Implement edit functionality
                    },
                  ),
                  DetailCard(title: 'Citizenship No.', value: getStringValue(userData['citizenshipNumber']), isEditable: false,onEdit: () {
                    // Implement edit functionality
                  null;}),
                  DetailCard(title: 'Issued Date', value: getStringValue(userData['issuedDate']),isEditable: false, onEdit: () {
                    // Implement edit functionality
                  }),
                  DetailCard(title: 'Issued District', value: getStringValue(userData['issuedDistrict']),isEditable: false, onEdit: () {
                    // Implement edit functionality
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xFF5218fa)),
      ),
    );
  }
}


class DetailCard extends StatelessWidget {
  final String title;
  final String? value;
  final bool isImage;
  final bool isEditable;
  final VoidCallback onEdit;

  DetailCard({required this.title, this.value, this.isImage = false, required this.isEditable, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002387),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  isImage
                      ? CachedNetworkImage(
                    imageUrl: value ?? '',
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: 80,
                    height: 70,
                  )
                      : Text(
                    value ?? 'No data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (isEditable)
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF321414)),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}