
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shimmer/shimmer.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String _gender = 'Male';
  bool isSaving =false;

  @override
  void initState() {
    super.initState();
    loadPageContent();
  }

  Future<void> loadPageContent() async {
    // Simulating a network call or some other async operation
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  // Controllers for the text fields
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final homeNumberController = TextEditingController();
  final stateController = TextEditingController();
  final jobController = TextEditingController();

  void showTopAlert(BuildContext context, String message, {bool isSuccess = true}) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // Function to save data to Firebase
  Future<void> saveToFirebase() async {
    setState(() {
      isSaving = true;
    });

    if (formKey.currentState!.validate()) {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'state': stateController.text,
          'homeAddress': addressController.text,
          'postal_code': postalCodeController.text,
          'home_number': homeNumberController.text,
          'job_title': jobController.text,
          'gender': _gender,
          'isProfileCompleted': true,
        });

        setState(() {
          isSaving = false;
        });

        if (formKey.currentState != null) {
          formKey.currentState!.reset();
        }

        stateController.clear();
        addressController.clear();
        postalCodeController.clear();
        homeNumberController.clear();
        jobController.clear();

        Navigator.pop(context, true);

        showTopAlert(context, 'Profile details saved successfully!');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Profile details saved successfully!')),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
    } else {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            text: 'Complete ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'Your',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              TextSpan(
                text: ' Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF37474F),
                Color(0xFFE0E0E0)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
    children:[isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
              child: Column(
                children: [
                  Container(
                    width:  MediaQuery.of(context).size.width,
                    height: 71.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width:  MediaQuery.of(context).size.width,
                    height: 71.0,
                    color: Colors.white,
                  ),

                ],
              ),
            );
          },
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 14),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: 'State/Province',
                    hintText: 'Bagmati',
                    prefixIcon: Icon(Icons.location_city_sharp),
                  ),
                  validator: (value) {
                    // Optional field, so no validation
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Home Address',
                    hintText: 'Municipality-Ward, District',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: postalCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Zip/Postal Code',
                    hintText: '90712 ',
                    prefixIcon: Icon(Icons.podcasts_sharp),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: homeNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Home Number',
                    hintText: 'Optional',
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    // Optional field, so no validation
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: jobController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Job title or Position',
                    hintText: 'e.g. Civil Engineer',
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gender:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Male',
                          groupValue: _gender,
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                        Text('Male'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Female',
                          groupValue: _gender,
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                        Text('Female'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Other',
                          groupValue: _gender,
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                        Text('Other'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveToFirebase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: const Color(0xFF6B7B8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Save Changes',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (isSaving)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ],
      ),
    );
  }
}
