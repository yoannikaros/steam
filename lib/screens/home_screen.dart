import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam/providers/auth_provider.dart';
import 'package:steam/screens/login_screen.dart';
import 'package:steam/screens/customer/customer_list_screen.dart';
import 'package:steam/screens/service/service_list_screen.dart';
import 'package:steam/screens/order/order_list_screen.dart';
import 'package:steam/screens/payment/payment_list_screen.dart';
import 'package:steam/screens/transaction/transaction_list_screen.dart';
import 'package:steam/screens/saving/saving_list_screen.dart';
import 'package:steam/screens/setting/setting_screen.dart';
import 'package:steam/screens/report/report_screen.dart';
import 'package:steam/screens/user/user_list_screen.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final OrderRepository _orderRepository = OrderRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _waitingOrders = 0;
  int _inProgressOrders = 0;
  int _doneOrders = 0;
  Map<String, double> _financialSummary = {
    'income': 0,
    'expense': 0,
    'profit': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final waitingOrders = await _orderRepository.getOrdersByStatus('waiting');
    final inProgressOrders = await _orderRepository.getOrdersByStatus('in_progress');
    final doneOrders = await _orderRepository.getOrdersByStatus('done');

    final firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final lastDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    final startDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    final endDate = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

    final summary = await _transactionRepository.getSummary(startDate, endDate);

    setState(() {
      _waitingOrders = waitingOrders.length;
      _inProgressOrders = inProgressOrders.length;
      _doneOrders = doneOrders.length;
      _financialSummary = summary;
    });
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220.0,
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
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                      fontSize: 24,
                  ),
                ),
                  background: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, top: 80, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang,',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              user?.username ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                        fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                      ),
                    ),
                      SizedBox(height: 20),
                      Container(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                      children: [
                            _buildStatusCard(
                            'Menunggu',
                            _waitingOrders.toString(),
                              Color(0xFFF59E0B),
                            Icons.hourglass_empty,
                          ),
                            SizedBox(width: 16),
                            _buildStatusCard(
                            'Proses',
                            _inProgressOrders.toString(),
                              Color(0xFF3B82F6),
                            Icons.directions_car,
                          ),
                            SizedBox(width: 16),
                            _buildStatusCard(
                            'Selesai',
                            _doneOrders.toString(),
                              Color(0xFF10B981),
                            Icons.check_circle,
                          ),
                          ],
                        ),
                    ),
                      SizedBox(height: 32),
                    Text(
                      'Ringkasan Keuangan',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                        fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                      ),
                    ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildFinancialItem(
                              'Pemasukan',
                              currencyFormat.format(_financialSummary['income']),
                                Color(0xFF10B981),
                              Icons.arrow_upward,
                            ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                            _buildFinancialItem(
                              'Pengeluaran',
                              currencyFormat.format(_financialSummary['expense']),
                                Color(0xFFEF4444),
                              Icons.arrow_downward,
                            ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                            _buildFinancialItem(
                              'Keuntungan',
                              currencyFormat.format(_financialSummary['profit']),
                                Color(0xFF6366F1),
                              Icons.account_balance,
                            ),
                          ],
                        ),
                      ),
                    ),
                      SizedBox(height: 32),
                    Text(
                      'Menu Cepat',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                        fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildQuickMenu(
                            'Pesanan',
                          Icons.add_circle,
                            Color(0xFF3B82F6),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderListScreen(initialTabIndex: 1),
                              ),
                            );
                          },
                        ),
                        _buildQuickMenu(
                            'Pelanggan',
                          Icons.people,
                            Color(0xFF10B981),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickMenu(
                            'Transaksi',
                          Icons.account_balance_wallet,
                            Color(0xFFF59E0B),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickMenu(
                          'Laporan',
                          Icons.bar_chart,
                            Color(0xFF8B5CF6),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ReportScreen()),
                            );
                          },
                        ),
                        _buildQuickMenu(
                          'Pengaturan',
                          Icons.settings,
                            Color(0xFF6B7280),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SettingScreen()),
                            );
                          },
                        ),
                        _buildQuickMenu(
                          'Tabungan',
                          Icons.savings,
                            Color(0xFF14B8A6),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SavingListScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenu(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
          color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context, dynamic user) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 240,
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
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                          size: 40,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      SizedBox(height: 16),
                    Text(
                      user?.username ?? 'User',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.role ?? 'Role',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                    ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
              _buildDrawerItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                    onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Pelanggan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CustomerListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.cleaning_services,
                title: 'Layanan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ServiceListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.receipt_long,
                title: 'Pesanan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.payment,
                title: 'Pembayaran',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.account_balance_wallet,
                title: 'Transaksi',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.savings,
                title: 'Tabungan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SavingListScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.bar_chart,
                title: 'Laporan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReportScreen()),
                  );
                },
              ),
              if (user?.role == 'admin')
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Pengguna',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserListScreen()),
                    );
                  },
                ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Pengaturan',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingScreen()),
                  );
                },
              ),
                  Divider(color: Color(0xFFE5E7EB), thickness: 1),
              _buildDrawerItem(
                icon: Icons.exit_to_app,
                title: 'Logout',
                onTap: _logout,
              ),
            ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
      leading: Icon(
        icon,
          color: Color(0xFF6366F1),
          size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        dense: true,
      ),
    );
  }
}
