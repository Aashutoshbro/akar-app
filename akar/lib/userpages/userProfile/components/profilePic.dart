import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum VerificationStatus {
  pending,
  verified,
  unverified,
}

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _profileImageURL;
  String? _username;
  String? _email;
  VerificationStatus verificationStatus = VerificationStatus.pending;
  bool _isLoading = true;
  File? _verifiedIcon;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await usersCollection.doc(currentUser.uid).get();

    setState(() {
      _profileImageURL = doc.data()?['profileImageURL'];
      _username = doc.data()?['name'];
      _email = currentUser.email;
      final status = doc.data()?['verificationStatus'] ?? 'pending';
      verificationStatus = VerificationStatus.values.firstWhere(
            (e) => e.toString() == 'VerificationStatus.$status',
        orElse: () => VerificationStatus.pending,
      );
    });

    await Future.wait([
      _loadProfileImage(),
      _loadVerifiedIcon(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProfileImage() async {
    if (_profileImageURL != null) {
      try {
        final file = await DefaultCacheManager().getSingleFile(_profileImageURL!);
        setState(() {
          _profileImage = file;
        });
      } catch (e) {
        print('Error loading profile image: $e');
      }
    }
  }

  Future<void> _loadVerifiedIcon() async {
    if (verificationStatus == VerificationStatus.verified) {
      try {
        final file = await DefaultCacheManager().getSingleFile('assets/verified.png');
        setState(() {
          _verifiedIcon = file;
        });
      } catch (e) {
        print('Error loading verified icon: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}.jpg');

      await storageRef.putFile(_profileImage!);
      final downloadURL = await storageRef.getDownloadURL();

      await usersCollection.doc(currentUser.uid).update({'profileImageURL': downloadURL});
      setState(() {
        _profileImageURL = downloadURL;
      });

      // Update cached image
      await DefaultCacheManager().downloadFile(downloadURL);
    }
  }

  Widget _buildShimmerCircleAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 115,
        width: 115,
        child: CircleAvatar(
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildShimmerText() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          Container(
            width: 100,
            height: 16,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        if (_username != null)
          Text(
            _username!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        if (_email != null)
          Text(
            _email!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isLoading
            ? _buildShimmerCircleAvatar()
            : SizedBox(
          height: 115,
          width: 115,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _profileImageURL != null
                    ? NetworkImage(_profileImageURL!)
                    : const AssetImage("assets/Profile Image.png") as ImageProvider,
              ),
              Positioned(
                right: -16,
                bottom: 0,
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFF5F6F9),
                    ),
                    onPressed: _pickImage,
                    child: SvgPicture.asset("assets/Camera Icon.svg"),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (verificationStatus == VerificationStatus.verified)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _verifiedIcon != null
                  ? Image.file(
                _verifiedIcon!,
                height: 24,
                width: 24,
              )
                  : Image.asset(
                'assets/verified.png',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 4),
              const Text(
                "Verified",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        _isLoading ? _buildShimmerText() : _buildTextFields(),
      ],
    );
  }
}