import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Controllers for form fields
  final TextEditingController _complaintDetailsController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // Variables to store selected values
  String? _category;
  String? _complaintType;
  String? _priorityLevel;
  String? _natureOfComplaint;

  @override
  void dispose() {
    _complaintDetailsController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<List<String>> _uploadImages(List<XFile> images, String complaintId) async {
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
          backgroundColor: Colors.green[100],
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Complaint ID: $complaintId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please keep this ID for future reference.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
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
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true; // Show progress indicator
      });

      try {
        // Create a new complaint document in Firestore
        final complaintRef = FirebaseFirestore.instance.collection('complaints').doc();
        final complaintId = complaintRef.id;

        // Upload images to Firebase Storage and get their URLs
        List<String> imageUrls = [];
        if (_selectedImages!.isNotEmpty) {
          imageUrls = await _uploadImages(_selectedImages!, complaintId);
        }

        // Save the complaint data in Firestore
        await complaintRef.set({
          'ticketNumber': complaintRef.id,
          'category': _category,
          'complaintType': _complaintType,
          'priorityLevel': _priorityLevel,
          'natureOfComplaint': _natureOfComplaint,
          'phoneNumber': _phoneNumberController.text,
          'complaintDetails': _complaintDetailsController.text,
          'location': location != null ? GeoPoint(location!.latitude, location!.longitude) : null,
          'address': address,
          'timestamp': FieldValue.serverTimestamp(),
          'images': imageUrls,
        });

        // Show a success message
        _showSuccessDialog(context, complaintRef.id);

        // Clear the form
        setState(() {
          _selectedImages!.clear();
          _complaintDetailsController.clear();
          _phoneNumberController.clear();
          _category = null;
          _complaintType = null;
          _priorityLevel = null;
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: <Widget>[
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: <String>[
                      'Roads',
                      'Side Walks',
                      'Bridges',
                      'Traffic Signals',
                      'Street Lights'
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
                      labelText: 'Complaint Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: <String>[
                      'Potholes',
                      'Cracked/Damaged Pavement',
                      'Flooding/Drainage Issues',
                      'Signage/Lighting Issues',
                      'Debris/Obstructions'
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
                  const SizedBox(height: 17),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Priority Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: <String>[
                      'Emergency/Immediate Attention',
                      'High',
                      'Medium',
                      'Low',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _priorityLevel = value;
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
                      'Immediate safety hazard',
                      'General maintenance request',
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
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 17),
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
                  const SizedBox(height: 17),
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
                      backgroundColor: Colors.blue,
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
                            height:
                                4), // Adds a small vertical gap between the two lines
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
                  const SizedBox(height: 20.0),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubmitting ? Colors.grey : Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple,
                            strokeWidth: 3,
                          ),
                        )
                            : const Text(
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
    );
  }
}
