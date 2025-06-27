import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:steam/providers/auth_provider.dart';
import 'package:steam/screens/login_screen.dart';
import 'package:steam/screens/user/change_username_screen.dart';
import 'package:steam/screens/user/change_password_screen.dart';
import 'package:steam/screens/user/delete_account_screen.dart';
import 'package:steam/screens/misc/terms_of_service_screen.dart';
import 'package:steam/screens/misc/privacy_policy_screen.dart';
import 'package:steam/screens/misc/contact_us_screen.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF818CF8),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  'Pengaturan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  // Account Section
                  Text(
                    'Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSettingGroup([
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: 'Ubah Username',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangeUsernameScreen()),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.delete_outline,
                      title: 'Hapus Akun',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeleteAccountScreen()),
                        );
                      },
                      isDestructive: true,
                    ),
                    _buildSettingItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      onTap: () {
                        _showLogoutDialog(context, authProvider);
                      },
                      isDestructive: true,
                    ),
                  ]),
                  SizedBox(height: 24),

                  // General Section
                  Text(
                    'Umum',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSettingGroup([
                    _buildSettingItem(
                      icon: Icons.star_border,
                      title: 'Beri Rating',
                      onTap: () {
                        // Handle rate us
                      },
                    ),
                  ]),
                  SizedBox(height: 24),

                  // Support Section
                  Text(
                    'Dukungan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSettingGroup([
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'Syarat Layanan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.security_outlined,
                      title: 'Kebijakan Privasi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: 'Hubungi Kami',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ContactUsScreen()),
                        );
                      },
                    ),
                  ]),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDestructive ? Color(0xFFEF4444) : Color(0xFF6366F1),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDestructive ? Color(0xFFEF4444) : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
