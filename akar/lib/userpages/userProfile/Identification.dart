import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class UploadId extends StatefulWidget {
  const UploadId({super.key});

  @override
  State<UploadId> createState() => _UploadIdState();
}

class _UploadIdState extends State<UploadId> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isMinor = false;
  File? _citizenshipImage;
  File? _schoolIdImage;
  String? _citizenshipNumber;
  String? _schoolName;
  String? _studentId;
  DateTime? _issuedDate;
  final _issuedDistrictController = TextEditingController();
  String? _issuedDistrict;

  final _issuedDateFormatter = MaskTextInputFormatter(
    mask: '####/##/##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _issuedDateController = TextEditingController();
  final _citizenshipController = TextEditingController();
  bool _isLoading = true; // Initialize to true
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<String?> _uploadImage(File imageFile, String userId) async {
    try {
      String imageName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imagePath = 'idImages/$imageName';

      await _storage.ref(imagePath).putFile(imageFile);
      return await _storage.ref(imagePath).getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  Future<void> _pickImages(ImageSource source, bool isSchoolId) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isSchoolId) {
          _schoolIdImage = File(pickedFile.path);
        } else {
          _citizenshipImage = File(pickedFile.path);
        }
      });
    }
  }
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

  void _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if ((!_isMinor && _citizenshipImage == null) ||
          (_isMinor && _schoolIdImage == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload the required image.')),
        );
        return;
      }

      _formKey.currentState?.save();
      setState(() {
        _isSaving = true;

      });

      String? imageUrl;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!_isMinor && _citizenshipImage != null) {
          imageUrl = await _uploadImage(_citizenshipImage!, user.uid);
        } else if (_isMinor && _schoolIdImage != null) {
          imageUrl = await _uploadImage(_schoolIdImage!, user.uid);
        }

        final updateData = {
          'isMinor': _isMinor,
          'citizenshipNumber': _isMinor ? null : _citizenshipNumber,
          'schoolName': _isMinor ? _schoolName : null,
          'studentId': _isMinor ? _studentId : null,
          'idImageURL': imageUrl,
          'isGovIdUploaded': true,
          'issuedDate': _issuedDate,
          'issuedDistrict': _issuedDistrict,
          'verificationStatus': 'pending',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);

        setState(() {
          _isSaving = false;

        });
        if (_formKey.currentState != null) {
          _formKey.currentState!.reset();
        }

        Navigator.pop(context, true);


        showTopAlert(context, 'Document uploaded successfully!');
      } else {
        setState(() {
          _isSaving = false;

        });

        showTopAlert(context, 'User not logged in.', isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: Stack(
    children: [
    _isLoading
          ? const ShimmerLoading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please enter details accurately for verification.',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('I am under 18 years old'),
                      value: _isMinor,
                      onChanged: (value) {
                        setState(() {
                          _isMinor = value;
                          _citizenshipNumber = '';
                          _citizenshipImage = null;
                          _schoolName = '';
                          _studentId = '';
                          _schoolIdImage = null;
                        });
                      },
                    ),
                    if (!_isMinor) ...[
                      TextFormField(
                        controller: _citizenshipController,
                        decoration: InputDecoration(
                          labelText: 'नागरिकता नम्बर ',
                          hintText: '12-01-88-89707 or 12347',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        onSaved: (value) => _citizenshipNumber = value!,
                      ),
                      const SizedBox(height: 17),

                      TextFormField(
                        controller: _issuedDateController,
                        decoration: InputDecoration(
                          labelText: 'नागरिकता जारी मिति (वि.सं.)',
                          hintText: '२०७९/०५/१५',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        inputFormatters: [_issuedDateFormatter],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!_issuedDateFormatter.isFill()) {
                            return 'Invalid date format';
                          }

                          final parts = value.split('/');
                          if (parts.length != 3) {
                            return 'Invalid date format';
                          }

                          final year = int.tryParse(parts[0]);
                          final month = int.tryParse(parts[1]);
                          final day = int.tryParse(parts[2]);

                          if (year == null || month == null || day == null) {
                            return 'Invalid date';
                          }

                          if (month < 1 || month > 12) {
                            return 'Invalid month (1-12)';
                          }

                          if (day < 1 || day > 32) {
                            return 'Invalid day (1-32)';
                          }

                          // Additional check for specific months with 30 days
                          if ([2, 4, 6, 9, 11].contains(month) && day > 31) {
                            return 'Invalid day for this month';
                          }

                          // Check for Falgun (month 11) which has 29 days in a leap year and 30 days otherwise
                          if (month == 11 && day > 30) {
                            return 'Invalid day for Falgun';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            final formattedValue = value.replaceAll('/', '-');
                            final nepaliDate = NepaliDateTime.tryParse(formattedValue);
                            final adDate = nepaliDate?.toDateTime();
                            _issuedDate = adDate;
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _issuedDistrictController,
                        decoration: InputDecoration(
                          labelText: 'नागरिकता जारी जिल्ला',
                          hintText: 'Kaski',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _issuedDistrict = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Upload Citizenship Front Card Image:'),
                      if (_citizenshipImage != null)
                        Image.file(_citizenshipImage!, height: 200),
                      ElevatedButton(
                        onPressed: () => _pickImages(ImageSource.camera, false),
                        child: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _pickImages(ImageSource.gallery, false),
                        child: const Text('Choose from Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'School Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            _isMinor && value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => _schoolName = value!,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Student ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            _isMinor && value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => _studentId = value!,
                      ),
                      const SizedBox(height: 20),
                      const Text('Upload School ID Image:'),
                      if (_schoolIdImage != null)
                        Image.file(_schoolIdImage!, height: 200),
                      ElevatedButton(
                        onPressed: () => _pickImages(ImageSource.camera, true),
                        child: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickImages(ImageSource.gallery, true),
                        child: const Text('Choose from Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: const Color(0xFF6A53A1),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
      if (_isSaving)
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

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  24.0), // Adjust the value to control the curvature
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  24.0), // Adjust the value to control the curvature
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            color: Colors.white,
          ),

        ],
      ),
    );
  }
}
