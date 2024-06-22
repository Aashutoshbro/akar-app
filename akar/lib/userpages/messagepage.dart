import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';


import '../Screens/mapscreen.dart';

class RegisterComplaintForm extends StatefulWidget {
  const RegisterComplaintForm({super.key});

  @override
  State<RegisterComplaintForm> createState() => _RegisterComplaintFormState();
}

class _RegisterComplaintFormState extends State<RegisterComplaintForm> {
  LatLng? location;
  String? address;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  bool _isSubmitting = false;
  //String _fullName = '';



  // Controllers for form fields
  final TextEditingController _complaintDetailsController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController  addressController = TextEditingController();

  // Variables to store selected values
  String? _category;
  String? _complaintType;
  String? _roadType;
  String? _natureOfComplaint;
  String _landmark = '';
  String _streetName = '';
  String _wardNumber = '';
  String? _duration;


  @override
  void dispose() {
    _complaintDetailsController.dispose();
    _phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<List<String>> _uploadImages(
      List<XFile> images, String complaintId) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('complaints/$complaintId/${image.name}');
      final uploadTask = await storageRef.putFile(File(image.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

//Picking the images
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else if (source == ImageSource.gallery) {
      await Permission.photos.request();
    }

    final status = await _requestPermission();
    if (status != PermissionStatus.granted) {
      return;
    }

    try {
      final List<XFile>? images =
          await _picker.pickMultiImage(imageQuality: 50);

      if (images != null) {
        if (_selectedImages!.length + images.length <= 3) {
          setState(() {
            _selectedImages!.addAll(images);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You can only select up to 3 images in total.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<PermissionStatus> _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();

    if (statuses[Permission.storage]!.isGranted &&
        statuses[Permission.camera]!.isGranted) {
      return PermissionStatus.granted;
    } else {
      if (kDebugMode) {
        print('No permission provided');
      }
    }
    return PermissionStatus.denied;
  }

  //validations

  String? validateComplaintType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a complaint type.';
    }
    return null;
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (!RegExp(r'^(98|97)\d{8}$').hasMatch(value)) {
      return 'Please enter a valid Nepali mobile number';
    }
    return null;
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        location = result['location'];
        address = result['address'];
      });
    }
  }

  void _showSuccessDialog(BuildContext context, String complaintId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.green[50],
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[800],
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your complaint has been submitted successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Complaint ID: $complaintId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please keep this ID for future reference.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true; // Show progress indicator
      });
      // Check verification status
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        final status = doc.data()?['verificationStatus'] ?? 'pending';
        if (status != 'verified') {
          String message = 'Please complete your profile and become a verified user to submit your complaint. This helps us better assist you.';
          showDialog(
            context: context,
            builder: (context) => OopsScreen(message: message),

          );
          setState(() {
            _isSubmitting = false; // Hide progress indicator
            _formKey.currentState!.reset();
            _selectedImages!.clear();
            _complaintDetailsController.clear();
            _phoneNumberController.clear();
            _category = null;
            _complaintType = null;
            _roadType = null;
            addressController.clear();
            _natureOfComplaint = null;
            location = null;
            address = null;
          });
          return;
        }
      }




      try {
        // Create a new complaint document in Firestore
        final complaintRef =
            FirebaseFirestore.instance.collection('complaints').doc();
        final complaintId = complaintRef.id;



        // Upload images to Firebase Storage and get their URLs
        List<String> imageUrls = [];
        if (_selectedImages!.isNotEmpty ) {
          imageUrls = await _uploadImages(_selectedImages!, complaintId);
        }

        // Save the complaint data in Firestore
        await complaintRef.set({
          'ticketNumber': complaintRef.id,
          'category': _category,
          'complaintType': _complaintType,
          'roadType': _roadType,
          'natureOfComplaint': _natureOfComplaint,
          'phoneNumber': _phoneNumberController.text,
          //'area': addressController.text,
          'duration':_duration,
          'landmark':_landmark,
          'streetName':_streetName,
          'wardNumber':_wardNumber,
          'complaintDetails': _complaintDetailsController.text,
          'location': location != null
              ? GeoPoint(location!.latitude, location!.longitude)
              : null,
          'address': address,
          'timestamp': FieldValue.serverTimestamp(),
          'images': imageUrls,

        });

        // Show a success message
        _showSuccessDialog(context, complaintRef.id);

        // Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages!.clear();
          _complaintDetailsController.clear();
          _phoneNumberController.clear();
          _category = null;
          _complaintType = null;
          _roadType = null;
          addressController.clear();
          _natureOfComplaint = null;
          location = null;
          address = null;

        });
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false; // Hide progress indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children:[ Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    // TextFormField(
                    //   decoration: InputDecoration(labelText: 'Full Name',border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),),
                    //   validator: (value) => value!.isEmpty ? 'Required' : null,
                    //   onSaved: (value) => _fullName = value!,
                    // ),
                    //
                    // const SizedBox(height:18),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Problem Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[
                        'Roads',
                        'Side Walks',
                        'Bridges',
                        'Traffic Signals',
                        'Street Lights',
                        'Public Transport Stops',

                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                    ),

                    const SizedBox(height: 17),
                    DropdownButtonFormField<String>(
                      validator: validateComplaintType,
                      decoration: InputDecoration(
                        labelText: 'Issue Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[
                        'Potholes',
                        'Cracked/Damaged Pavement',
                        'Flooding/Drainage Issues',
                        'Signage/Lighting Issues',
                        'Debris/Obstructions',
                        'Traffic Disruption',
                        'Public Transport Issue',
                        'Fallen Trees',
                        'Damaged Bus/Taxi Stand',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _complaintType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 17,),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Duration of Issue',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[
                        'Just Noticed',
                        'Few Days',
                        'Few Weeks',
                        'More than a Month',
                        'Unsure',


                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _duration = value;
                        });
                      },
                    ),
                    const SizedBox(height: 17),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Road Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[
                        'National Highway',
                        'State Road',
                        'Rural Road',
                        'City Street',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _roadType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 17),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Nature of Complaint',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>[

                        'High (Major disruption, safety risk)',
                        'Medium (Significant inconvenience)',
                        'Low (General maintenance request)',

                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _natureOfComplaint = value;
                        });
                      },
                    ),
                    const SizedBox(height: 17),
                    TextFormField(
                      controller: _phoneNumberController,
                      validator: validateMobileNumber,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    // SizedBox(height: 17),
                    //
                    // TextFormField(
                    //   controller: addressController,
                    //   decoration:  InputDecoration(
                    //     labelText:  'Affected Area',
                    //     hintText: 'Municipality-Ward, District',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter affected site';
                    //     }
                    //     return null;
                    //   },
                    // ),

                    SizedBox(height: 17),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Landmark',
                        hintText: 'e.g. near Utech Clz',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),// Add this line for hint text
                      ),
                      onSaved: (value) => _landmark = value!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Street Name',
                        hintText: 'e.g. Bishal Chowk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),// Add this line for hint text
                      ),
                      onSaved: (value) => _streetName = value!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ward Number',
                        hintText: 'e.g. 11',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),// Add this line for hint text
                      ),
                      onSaved: (value) => _wardNumber = value!,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _complaintDetailsController,
                      decoration: InputDecoration(
                        labelText: 'Complaint Details',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a photo'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final XFile? photo = await _picker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    if (photo != null) {
                                      setState(() {
                                        if (_selectedImages!.length < 3) {
                                          _selectedImages!.add(photo);
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'You can only select up to 3 images.'),
                                              ),
                                            );
                                          }
                                        }
                                      });
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text('Choose from gallery'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade800,
                        minimumSize: const Size(160, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      icon: const Icon(Icons.photo, color: Colors.white),
                      label: const Text(
                        'Choose File',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    if (_selectedImages!.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _selectedImages!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Image.file(
                                File(_selectedImages![index].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages!.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    color: Colors.redAccent,
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 17),
                    ElevatedButton.icon(
                      onPressed: _selectLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        minimumSize: const Size(160, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_outlined,
                          color: Colors.white),
                      label: Text(
                        location == null ? 'Select Location' : 'Change Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (location != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${location!.latitude}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(
                              height:4,),

                          Text(
                            'Longitude: ${location!.longitude}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (address != null)
                            Text(
                              'Address: $address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubmitting
                                ? Colors.greenAccent
                                : Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
    ],

      ),
    );
  }
}


class OopsScreen extends StatelessWidget {
  final String message;

  OopsScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/oops.png'),
              SizedBox(height: 20),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                },
                child: Text(
                  'TRY AGAIN',
                  style: TextStyle(fontWeight: FontWeight.bold),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
