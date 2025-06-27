import 'package:flutter/material.dart';
import 'package:steam/repositories/payment_repository.dart';
import 'package:steam/screens/order/order_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentListScreen extends StatefulWidget {
  @override
  _PaymentListScreenState createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> with SingleTickerProviderStateMixin {
  final PaymentRepository _paymentRepository = PaymentRepository();
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPayments = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payments = await _paymentRepository.getPaymentsWithOrderDetails();
      double total = 0;
      for (var payment in payments) {
        total += payment['amount'] as double;
      }
      
      setState(() {
        _payments = payments;
        _filteredPayments = payments;
        _totalAmount = total;
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

  void _filterPayments(String query) {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final customerName = payment['customer_name']?.toString().toLowerCase() ?? '';
        final serviceName = payment['service_name'].toString().toLowerCase();
        final method = payment['method']?.toString().toLowerCase() ?? 'tunai';
        final searchQuery = query.toLowerCase();
        
        return customerName.contains(searchQuery) ||
               serviceName.contains(searchQuery) ||
               method.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _deletePayment(int id) async {
    try {
      await _paymentRepository.deletePayment(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPayments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pembayaran ini? Tindakan ini tidak dapat dibatalkan.',
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
              Navigator.pop(context);
              _deletePayment(id);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
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
                  'Daftar Pembayaran',
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
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Text(
                        'Total Pembayaran',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 20,
                      right: 20,
                      child: Text(
                        currencyFormat.format(_totalAmount),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPayments,
                    decoration: InputDecoration(
                      hintText: 'Cari pembayaran...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6366F1)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredPayments.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada data pembayaran',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final payment = _filteredPayments[index];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(orderId: payment['order_id']),
                                      ),
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
                                                payment['service_name'],
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
                                                currencyFormat.format(payment['amount']),
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
                                              payment['customer_name'] ?? 'Pelanggan umum',
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
                                              payment['payment_date'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              Icons.payment,
                                              size: 16,
                                              color: Color(0xFF6B7280),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              payment['method'] ?? 'Tunai',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                              icon: Icon(Icons.receipt_long, color: Color(0xFF6366F1)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(orderId: payment['order_id']),
                                    ),
                                  );
                                },
                                              tooltip: 'Lihat Detail',
                              ),
                              IconButton(
                                              icon: Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(payment['id']),
                                              tooltip: 'Hapus',
                                            ),
                                          ],
                              ),
                            ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                        childCount: _filteredPayments.length,
                  ),
                    ),
        ],
                ),
    );
  }
}
