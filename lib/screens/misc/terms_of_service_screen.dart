import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service', style: GoogleFonts.poppins()),
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
              'Terms of Service',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: June 2024\n',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              'Please read these Terms of Service ("Terms", "Terms of Service") carefully before using this application. By accessing or using the app, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the app.',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            SizedBox(height: 20),
            Text('1. Use of the App', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('You must be at least 13 years old to use this app. You agree to use the app only for lawful purposes and in accordance with these Terms.'),
            SizedBox(height: 16),
            Text('2. User Accounts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.'),
            SizedBox(height: 16),
            Text('3. Intellectual Property', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('All content, features, and functionality in this app are the exclusive property of the app owner and are protected by copyright and other laws.'),
            SizedBox(height: 16),
            Text('4. Termination', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('We may terminate or suspend your access to the app immediately, without prior notice or liability, for any reason whatsoever.'),
            SizedBox(height: 16),
            Text('5. Limitation of Liability', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('In no event shall the app owner be liable for any indirect, incidental, special, consequential or punitive damages arising out of your use of the app.'),
            SizedBox(height: 16),
            Text('6. Changes to Terms', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('We reserve the right to modify or replace these Terms at any time. Changes will be effective immediately upon posting.'),
            SizedBox(height: 16),
            Text('7. Contact Us', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('If you have any questions about these Terms, please contact us through the Contact Us page in the app.'),
            SizedBox(height: 32),
            Text('By using this app, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
} 