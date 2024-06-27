import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

enum VerificationStatus {
  pending,
  verified,
  unverified,
}

class Cprofile extends StatefulWidget {
  const Cprofile({super.key});

  @override
  State<Cprofile> createState() => _CprofileState();
}

class _CprofileState extends State<Cprofile> {
  bool isProfileDetailsCompleted = false;
  bool isGovIdUploaded = false;
  VerificationStatus verificationStatus = VerificationStatus.pending;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAndSyncCompletionStatus();
  }

  Future<void> loadAndSyncCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'verificationStatus': 'pending',
          'isProfileCompleted': false,
          'isGovIdUploaded': false,
        });
      }
      final data = doc.data()!;
      final status = data['verificationStatus'] ?? 'pending';
      final profileStatus = data['isProfileCompleted'] ?? false;
      final govIdStatus = data['isGovIdUploaded'] ?? false;

      setState(() {
        isProfileDetailsCompleted = profileStatus;
        isGovIdUploaded = govIdStatus;
        verificationStatus = VerificationStatus.values.firstWhere(
          (e) => e.toString() == 'VerificationStatus.$status',
          orElse: () => VerificationStatus.pending,
        );
        isLoading = false;
      });

      // Save the fetched data to SharedPreferences
      await prefs.setBool(
          'isProfileDetailsCompleted', isProfileDetailsCompleted);
      await prefs.setBool('isGovIdUploaded', isGovIdUploaded);
      await prefs.setString(
          'verificationStatus', verificationStatus.toString().split('.').last);
    } else {
      // If user is null, load local state
      setState(() {
        isProfileDetailsCompleted =
            prefs.getBool('isProfileDetailsCompleted') ?? false;
        isGovIdUploaded = prefs.getBool('isGovIdUploaded') ?? false;
        final status = prefs.getString('verificationStatus') ?? 'pending';
        verificationStatus = VerificationStatus.values.firstWhere(
          (e) => e.toString() == 'VerificationStatus.$status',
          orElse: () => VerificationStatus.pending,
        );
        isLoading = false;
      });
    }

    print("Loaded Profile Details Completed: $isProfileDetailsCompleted");
    print("Loaded Gov ID Uploaded: $isGovIdUploaded");
    print("Loaded Verification Status: $verificationStatus");
  }

  Future<void> saveCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileDetailsCompleted', isProfileDetailsCompleted);
    await prefs.setBool('isGovIdUploaded', isGovIdUploaded);
    await prefs.setString(
        'verificationStatus', verificationStatus.toString().split('.').last);
    print("Saved Profile Details Completed: $isProfileDetailsCompleted");
    print("Saved Gov ID Uploaded: $isGovIdUploaded");
    print("Saved Verification Status: $verificationStatus");
  }

  Future<void> navigateToProfileDetails() async {
    final result = await Navigator.pushNamed(context, '/profile-details');
    if (result == true) {
      setState(() {
        isProfileDetailsCompleted = true;
      });
      await saveCompletionStatus();
    }
  }

  Future<void> navigateToUploadGovId() async {
    final result = await Navigator.pushNamed(context, '/upload-gov-id');
    if (result == true) {
      setState(() {
        isGovIdUploaded = true;
      });
      await saveCompletionStatus();
    }
  }

  Future<void> _refreshProfile() async {
    await loadAndSyncCompletionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 9.0,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 9.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 190, // Constrain the height of the ListView
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 160,
                              child: Card(
                                child: Container(
                                  height: 100,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                          const Padding(padding: EdgeInsets.only(right: 4)),
                          itemCount: 2,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (verificationStatus == VerificationStatus.unverified)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red[100],
                    child: Text(
                      "Your profile information was found to be misleading. Please reset your profile details and complete the profile again.",
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                if (!isGovIdUploaded &&
                    !isProfileDetailsCompleted &&
                    verificationStatus == VerificationStatus.pending)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.yellow[100],
                    child: Text(
                      "Please update your profile details and verify your identity to access our services conveniently.",
                      style: TextStyle(color: Colors.yellow[900]),
                    ),
                  ),
                if (isGovIdUploaded &&
                    isProfileDetailsCompleted &&
                    verificationStatus == VerificationStatus.pending)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green[100],
                    child: Text(
                      "Your profile is under review. Thank you for completing the necessary steps.",
                      style: TextStyle(color: Colors.green[900]),
                    ),
                  ),
                if (verificationStatus == VerificationStatus.verified)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green[100],
                    child: Text(
                      "Thank you for verifying your profile. You can now lodge your complaints or access our services without any hassle.",
                      style: TextStyle(color: Colors.green[800]),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        "Complete Your Profile",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      isProfileDetailsCompleted && isGovIdUploaded
                          ? verificationStatus == VerificationStatus.verified
                          ? "Verified"
                          : verificationStatus == VerificationStatus.unverified
                          ? "Unverified"
                          : "Validation in progress"
                          : "(${(isProfileDetailsCompleted ? 1 : 0) + (isGovIdUploaded ? 1 : 0)}/2)",
                      style: TextStyle(
                        color: verificationStatus == VerificationStatus.verified
                            ? Colors.green
                            : verificationStatus == VerificationStatus.unverified
                            ? Colors.red
                            : Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double itemWidth = constraints.maxWidth * 0.4; // 40% of the screen width

                    return Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Container(
                            height: 7,
                            margin: EdgeInsets.only(right: index == 1 ? 2 : 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: (index == 0 && isProfileDetailsCompleted) ||
                                  (index == 1 && isGovIdUploaded)
                                  ? Colors.lightBlue
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double itemWidth = constraints.maxWidth * 0.50; // 50% of the screen width
                    double buttonWidth = itemWidth - 30; // reduce padding for the button width

                    return SizedBox(
                      height: 190, // Constrain the height of the ListView
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final card = pc[index];
                          return Container(
                            width: itemWidth,
                            child: Card(
                              shadowColor: Colors.black87,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      card.icon,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      card.title,
                                      textAlign: TextAlign.center,
                                    ),
                                    const Spacer(),
                                    FittedBox(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          switch (index) {
                                            case 0:
                                              if (!isProfileDetailsCompleted ||
                                                  verificationStatus == VerificationStatus.unverified) {
                                                navigateToProfileDetails();
                                              }
                                              break;
                                            case 1:
                                              if (!isGovIdUploaded ||
                                                  verificationStatus == VerificationStatus.unverified) {
                                                navigateToUploadGovId();
                                              }
                                              break;
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (index == 0 &&
                                              isProfileDetailsCompleted &&
                                              verificationStatus == VerificationStatus.verified) ||
                                              (index == 1 &&
                                                  isGovIdUploaded &&
                                                  verificationStatus == VerificationStatus.verified)
                                              ? Colors.grey
                                              : verificationStatus == VerificationStatus.unverified
                                              ? Colors.red
                                              : Colors.lightBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          minimumSize: Size(buttonWidth, 36), // Set button width dynamically
                                        ),
                                        child: Text((index == 0 &&
                                            isProfileDetailsCompleted &&
                                            verificationStatus == VerificationStatus.verified) ||
                                            (index == 1 &&
                                                isGovIdUploaded &&
                                                verificationStatus == VerificationStatus.verified)
                                            ? "Verified"
                                            : verificationStatus == VerificationStatus.unverified
                                            ? "Reset"
                                            : isGovIdUploaded &&
                                            verificationStatus == VerificationStatus.pending &&
                                            index == 1
                                            ? "Processing"
                                            : card.buttonText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.only(right: 4)),
                        itemCount: pc.length,
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;

  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

List<ProfileCompletionCard> pc = [
  ProfileCompletionCard(
    title: "Set Your Profile Details",
    icon: CupertinoIcons.person_circle,
    buttonText: "Continue",
  ),
  ProfileCompletionCard(
    title: "Upload your Gov-Id Documents",
    icon: CupertinoIcons.doc,
    buttonText: "Upload",
  ),
];