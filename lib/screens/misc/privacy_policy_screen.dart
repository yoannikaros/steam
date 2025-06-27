import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: June 2024\n',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              'This Privacy Policy explains our policy regarding the collection, use, and disclosure of your information. This policy applies to our application which operates completely offline.',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            SizedBox(height: 20),
            _buildSection(
              '1. No Data Collection',
              'We do not collect, store, or transmit any personal or sensitive user data. Our application is designed to be 100% offline and does not require an internet connection to function. All data created or managed by this application is stored locally on your device and is never sent to us or any third party.',
            ),
            _buildSection(
              '2. Data Storage',
              'All data, including but not limited to user-generated content, settings, and application data, is stored exclusively on your device\'s local storage. You have full control over your data. Uninstalling the application will permanently delete all of its data from your device.',
            ),
            _buildSection(
              '3. Permissions',
              'Our application may request certain permissions to function correctly (e.g., storage access). These permissions are used solely for the application\'s core offline functionality and are not used to access your personal information for any other purpose.',
            ),
            _buildSection(
              '4. Third-Party Services',
              'This application does not integrate with any third-party services, analytics, or advertising networks. There are no external links or services that would lead to data collection by external parties.',
            ),
            _buildSection(
              '5. Children’s Privacy',
              'Since our application does not collect any personal data, it is safe for use by individuals of all ages, including children. We do not knowingly collect any information from any user.',
            ),
            _buildSection(
              '6. Changes to This Policy',
              'We may update this Privacy Policy in the future if the application\'s functionality changes. Any changes will be posted on this page, and we will update the "Last updated" date.',
            ),
            _buildSection(
              '7. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us through the Contact Us page in the app.',
            ),
            SizedBox(height: 32),
            Text(
              'By using this app, you acknowledge and agree to this privacy policy.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text(content, style: GoogleFonts.poppins(fontSize: 15, height: 1.5)),
        SizedBox(height: 20),
      ],
    );
  }
} 