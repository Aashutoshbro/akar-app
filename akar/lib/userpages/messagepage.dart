import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isLoading = true;

  // Controllers for form fields
  final TextEditingController _complaintDetailsController =
  TextEditingController();

  final TextEditingController addressController = TextEditingController();

  // Variables to store selected values
  String? _category;
  String? _complaintType;
  String? _customCategory;
  String? _customIssueType;
  String? _natureOfComplaint;
  String _landmark = '';
  String _streetName = '';

  //String _wardNumber = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _complaintDetailsController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Perform any initial data loading here
    // For example, you might want to check if the user has already uploaded an ID

    // Simulate a delay for demonstration purposes
    await Future.delayed(Duration(seconds: 1));

    // When done, set _isLoading to false
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<String>> _uploadImages(List<XFile> images,
      String complaintId) async {
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.check_circle,
                  color: Colors.green[800],
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Your complaint has been submitted successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Complaint ID: $complaintId',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please keep this ID for future reference.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Optionally, navigate to a new screen or refresh the current one
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ),
              ],
            ),
          ),
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
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final status = doc.data()?['verificationStatus'] ?? 'pending';
        if (status != 'verified') {
          String message =
              'Please complete your profile and become a verified user to submit your complaint. This helps us better assist you.';
          showDialog(
            context: context,
            builder: (context) => OopsScreen(message: message),
          );
          setState(() {
            _isSubmitting = false; // Hide progress indicator
            _formKey.currentState!.reset();
            _selectedImages!.clear();
            _complaintDetailsController.clear();
            addressController.clear();
            _category = null;
            _complaintType = null;
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
        if (_selectedImages!.isNotEmpty) {
          imageUrls = await _uploadImages(_selectedImages!, complaintId);
        }

        final String finalCategory = _category == 'Other' ? _customCategory ??
            'Other' : _category ?? 'Unknown';
        final String finalComplaintType = _category == 'Other' ||
            _complaintType == 'Other'
            ? _customIssueType ?? 'Other'
            : _complaintType ?? 'Unknown';

        // Save the complaint data in Firestore
        await complaintRef.set({
          'userID': currentUser?.uid,
          'ticketNumber': complaintRef.id,
          'category': finalCategory,
          'complaintType': finalComplaintType,
          'natureOfComplaint': _natureOfComplaint,
          'area': addressController.text,
          'landmark': _landmark,
          'streetName': _streetName,
          //'wardNumber': _wardNumber,
          'complaintDetails': _complaintDetailsController.text,
          'location': location != null
              ? GeoPoint(location!.latitude, location!.longitude)
              : null,
          'address': address,
          'timestamp': FieldValue.serverTimestamp(),
          'images': imageUrls,
          'status':'In Progress',
        });

        // Show a success message
        _showSuccessDialog(context, complaintRef.id);

        // Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages!.clear();
          _complaintDetailsController.clear();
          addressController.clear();
          _category = null;
          _complaintType = null;
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
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double formWidth = screenWidth > 600 ? 600 : screenWidth * 0.9;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: formWidth),
                  child: _isLoading
                      ? const ShimmerLoading()
                      : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        _buildProblemCategoryField(),
                        const SizedBox(height: 17),
                        _buildIssueTypeField(),
                        if (_category != 'Other' && _complaintType == 'Other')
                          Padding(
                            padding: const EdgeInsets.only(top: 17.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Specify Other Issue Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _customIssueType = value;
                                });
                              },
                            ),
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
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Affected Area',
                            hintText: 'Municipality-Ward, District',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter affected site';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 17),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Landmark',
                            hintText: 'e.g. near Utech Clz',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSaved: (value) => _landmark = value!,
                        ),
                        const SizedBox(height: 17),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Street Name',
                            hintText: 'e.g. Bishal Chowk',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSaved: (value) => _streetName = value!,
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
                                      leading:
                                      const Icon(Icons.camera_alt),
                                      title: const Text('Take a photo'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final XFile? photo =
                                        await _picker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                        if (photo != null) {
                                          setState(() {
                                            if (_selectedImages!.length <
                                                3) {
                                              _selectedImages!.add(photo);
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                    context)
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
                                      title: const Text(
                                          'Choose from gallery'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await _pickImage(
                                            ImageSource.gallery);
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
                          icon: const Icon(Icons.photo,
                              color: Colors.white),
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
                            itemBuilder:
                                (BuildContext context, int index) {
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
                                          _selectedImages!
                                              .removeAt(index);
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
                            location == null
                                ? 'Select Location'
                                : 'Change Location',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (location != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latitude: ${location!.latitude}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Longitude: ${location!.longitude}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (address != null)
                                Text(
                                  'Address: $address',
                                  style: const TextStyle(
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
                              onPressed:
                              _isSubmitting ? null : _submitForm,
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
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildProblemCategoryField() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Problem Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _category,
          items: <String>[
            'Roads and Traffic',
            'Sidewalks and Pedestrian Areas',
            'Public Transportation',
            'Parks and Public Spaces',
            'Utilities and Infrastructure',
            'Waste Management',
            'Other',
          ].toSet().map((String value) { // Ensure uniqueness with .toSet()
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _category = value;
              _complaintType = null;
              _customCategory = null;
              _customIssueType = null;
            });
          },
        ),
        if (_category == 'Other')
          Padding(
            padding: const EdgeInsets.only(top: 17.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Specify Other Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _customCategory = value;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildIssueTypeField() {
    if (_category == 'Other') {
      return TextFormField(
        decoration: InputDecoration(
          labelText: 'Specify Issue Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _customIssueType = value;
          });
        },
      );
    }

    List<String> issueTypes = _getIssueTypesForCategory(_category).toSet().toList(); // Ensure uniqueness

    return Column(
      children: [
        DropdownButtonFormField<String>(
          validator: validateComplaintType,
          decoration: InputDecoration(
            labelText: 'Issue Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _complaintType,
          items: issueTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _complaintType = value;
              if (value == 'Other') {
                _customIssueType = null;
              }
            });
          },
        ),
        // if (_complaintType == 'Other')
        //   Padding(
        //     padding: const EdgeInsets.only(top: 17.0),
        //     child: TextFormField(
        //       decoration: InputDecoration(
        //         labelText: 'Specify Other Issue Type',
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //       ),
        //       onChanged: (value) {
        //         setState(() {
        //           _customIssueType = value;
        //         });
        //       },
        //     ),
        //   ),
      ],
    );
  }

  List<String> _getIssueTypesForCategory(String? category) {
    switch (category) {
      case 'Roads and Traffic':
        return [
          'Potholes',
          'Road damage',
          'Traffic light malfunction',
          'Street sign issues',
          'Road markings faded',
          'Flooding on road',
          'Illegal parking',
          'Other',
        ];
      case 'Sidewalks and Pedestrian Areas':
        return [
          'Broken sidewalk',
          'Obstructed walkway',
          'Poor lighting',
          'Other',
        ];
      case 'Public Transportation':
        return [
          'Bus stop damage',
          'Cleanliness issues',
          'Other',
        ];
      case 'Parks and Public Spaces':
        return [
          'Damaged playground equipment',
          'Overgrown vegetation',
          'Vandalism',
          'Lack of lighting',
          'Litter or trash',
          'Other',
        ];
      case 'Utilities and Infrastructure':
        return [
          'Street light out',
          'Water leak',
          'Sewer(wastewater) overflow',
          'Damaged drain cover',
          'Fallen power lines',
          'Fallen Trees',
          'Other',
        ];
      case 'Waste Management':
        return [
          'Missed garbage collection',
          'Overflowing public trash bin',
          'Illegal dumping',
          'Recycling issues',
          'Other',
        ];

      case 'Other':
        return ['Please specify'];
      default:
        return ['Other'];
    }
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

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < 8; i++) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              height: 65.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            const SizedBox(height: 4.0),
          ],
          for (int i = 0; i < 2; i++) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              height: 48.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

