import 'package:akar/userpages/userProfile/components/UserFunctions/perosnalDetails.dart';
import 'package:akar/userpages/userProfile/components/UserFunctions/settings/changePasswordPage.dart';
import 'package:flutter/material.dart';
import 'package:akar/userpages/userProfile/components/UserFunctions/invite_page.dart';

class UserSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection(
            'Account',
            [
              _buildListTile(
                'Edit Profile',
                Icons.person_outline,
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PersonalInformationPage()),
                      );

                },
              ),
              _buildListTile(
                'Change Password',
                Icons.lock_outline,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                'Push Notifications',
                Icons.notifications_none,
                true,
                    (bool value) {
                  // Handle push notifications toggle
                },
              ),
              _buildSwitchTile(
                'Email Notifications',
                Icons.email_outlined,
                false,
                    (bool value) {
                  // Handle email notifications toggle
                },
              ),
            ],
          ),
          _buildSection(
            'More',
            [
              _buildListTile(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                    () {
                  // Navigate to Privacy Policy page
                },
              ),
              _buildListTile(
                'Terms of Service',
                Icons.description_outlined,
                    () {
                  // Navigate to Terms of Service page
                },
              ),
              _buildListTile(
                'Log Out',
                Icons.exit_to_app,
                    () {
                  // Handle log out
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...children,
        Divider(),
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}