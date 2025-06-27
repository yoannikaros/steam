import 'package:flutter/material.dart';
import 'package:steam/repositories/transaction_repository.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/repositories/saving_repository.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final SavingRepository _savingRepository = SavingRepository();

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  Map<String, double> _financialSummary = {
    'income': 0,
    'expense': 0,
    'profit': 0,
  };

  List<Map<String, dynamic>> _orders = [];
  double _totalSavings = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    initializeDateFormatting('id');
    _loadReportData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

      final summary = await _transactionRepository.getSummary(startDateStr, endDateStr);
      final orders = await _orderRepository.getOrdersWithDetails();
      final totalSavings = await _savingRepository.getTotalSavings();

      // Filter orders by date range
      final filteredOrders = orders.where((order) {
        try {
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']);
          return orderDate.isAfter(_startDate.subtract(Duration(days: 1))) &&
              orderDate.isBefore(_endDate.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();

      setState(() {
        _financialSummary = summary;
        _orders = filteredOrders;
        _totalSavings = totalSavings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _loadReportData();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                'Laporan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
            centerTitle: false,
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
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Color(0xFF6366F1),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF6366F1),
                  unselectedLabelColor: Color(0xFF6B7280),
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(text: 'Keuangan'),
                    Tab(text: 'Pesanan'),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Dari Tanggal',
                              labelStyle: GoogleFonts.poppins(),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_startDate),
                                  style: GoogleFonts.poppins(),
                                ),
                                Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sampai Tanggal',
                              labelStyle: GoogleFonts.poppins(),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_endDate),
                                  style: GoogleFonts.poppins(),
                                ),
                                Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
                        ],
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
          SliverFillRemaining(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildFinancialReport(currencyFormat),
                _buildOrderReport(currencyFormat),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReport,
        icon: Icon(Icons.download),
        label: Text(
          'Ekspor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildFinancialReport(NumberFormat currencyFormat) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Keuangan',
              style: GoogleFonts.poppins(
                fontSize: 20,
              fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 16),
          Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            child: Padding(
              padding: EdgeInsets.all(16),
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
          SizedBox(height: 24),
          Text(
            'Tabungan',
              style: GoogleFonts.poppins(
                fontSize: 20,
              fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 16),
          Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                    Icons.savings,
                        size: 32,
                        color: Color(0xFF6366F1),
                      ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Tabungan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currencyFormat.format(_totalSavings),
                            style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                              color: _totalSavings >= 0 ? Color(0xFF6366F1) : Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderReport(NumberFormat currencyFormat) {
    int totalOrders = _orders.length;
    int completedOrders = _orders.where((order) => order['status'] == 'done').length;
    int cancelledOrders = _orders.where((order) => order['status'] == 'cancelled').length;
    int inProgressOrders = _orders.where((order) => order['status'] == 'in_progress').length;
    int waitingOrders = _orders.where((order) => order['status'] == 'waiting').length;
    double totalRevenue = 0;

    for (var order in _orders) {
      if (order['status'] == 'done') {
        totalRevenue += (order['total_price'] ?? order['service_price']) as double;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
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
          SizedBox(height: 16),
            Container(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
            children: [
                  _buildStatCard('Total', totalOrders.toString(), Color(0xFF6366F1), Icons.receipt_long),
                  SizedBox(width: 12),
                  _buildStatCard('Selesai', completedOrders.toString(), Color(0xFF10B981), Icons.check_circle),
                  SizedBox(width: 12),
                  _buildStatCard('Proses', inProgressOrders.toString(), Color(0xFF3B82F6), Icons.directions_car),
                  SizedBox(width: 12),
                  _buildStatCard('Menunggu', waitingOrders.toString(), Color(0xFFF59E0B), Icons.hourglass_empty),
                  SizedBox(width: 12),
                  _buildStatCard('Batal', cancelledOrders.toString(), Color(0xFFEF4444), Icons.cancel),
                ],
              ),
          ),
            SizedBox(height: 24),
          Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                    Icons.payments,
                        size: 32,
                        color: Color(0xFF10B981),
                      ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pendapatan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currencyFormat.format(totalRevenue),
                            style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Daftar Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 20,
              fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 16),
          _orders.isEmpty
              ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        margin: EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-detail',
                              arguments: order['id'],
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order['service_name'] ?? 'Layanan tidak ditemukan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF6366F1).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        currencyFormat.format(order['total_price'] ?? order['service_price']),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      order['customer_name'] ?? 'Pelanggan umum',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                    SizedBox(width: 8),
                      Text(
                                      '${order['date']} ${order['time']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatusBadge(order['status']),
                          SizedBox(width: 8),
                          _buildPaymentBadge(order['is_paid']),
                        ],
                      ),
                    ],
                  ),
                          ),
                ),
              );
            },
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

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'waiting':
        color = Color(0xFFF59E0B);
        text = 'Menunggu';
        icon = Icons.hourglass_empty;
        break;
      case 'in_progress':
        color = Color(0xFF3B82F6);
        text = 'Diproses';
        icon = Icons.directions_car;
        break;
      case 'done':
        color = Color(0xFF10B981);
        text = 'Selesai';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Color(0xFFEF4444);
        text = 'Batal';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
      ),
          SizedBox(width: 6),
          Text(
        text,
            style: GoogleFonts.poppins(
          fontSize: 12,
              fontWeight: FontWeight.w600,
          color: color,
            ),
        ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(int isPaid) {
    Color color = isPaid == 1 ? Color(0xFF10B981) : Color(0xFFEF4444);
    String text = isPaid == 1 ? 'Lunas' : 'Belum Bayar';
    IconData icon = isPaid == 1 ? Icons.check_circle : Icons.money_off;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
      ),
          SizedBox(width: 6),
          Text(
        text,
            style: GoogleFonts.poppins(
          fontSize: 12,
              fontWeight: FontWeight.w600,
          color: color,
            ),
        ),
      ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ekspor Laporan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih format ekspor laporan:',
              style: GoogleFonts.poppins(),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                'PDF',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              onTap: () {
                Navigator.pop(context);
                _showExportMessage('PDF');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            ListTile(
              title: Text(
                'Excel',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.table_chart, color: Colors.green),
              onTap: () {
                Navigator.pop(context);
                _showExportMessage('Excel');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            ListTile(
              title: Text(
                'CSV',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.description, color: Colors.blue),
              onTap: () {
                Navigator.pop(context);
                _showExportMessage('CSV');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportMessage(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan berhasil diekspor dalam format $format',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
