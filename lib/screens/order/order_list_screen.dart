import 'package:flutter/material.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/screens/order/order_form_screen.dart';
import 'package:steam/screens/order/order_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderListScreen extends StatefulWidget {
  final int initialTabIndex;

  OrderListScreen({this.initialTabIndex = 0});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with TickerProviderStateMixin {
  final OrderRepository _orderRepository = OrderRepository();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadOrders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderRepository.getOrdersWithDetails();
      setState(() {
        _orders = orders;
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredOrders(String status) {
    if (status == 'all') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == status).toList();
  }

  Future<void> _navigateToAddOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderFormScreen(),
      ),
    );

    if (result != null && result) {
      _loadOrders();
    }
  }

  Future<void> _navigateToOrderDetail(Map<String, dynamic> order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order['id']),
      ),
    );

    if (result != null && result) {
      _loadOrders();
    }
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    try {
      await _orderRepository.updateOrderStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diperbarui'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteOrder(int id) async {
    try {
      await _orderRepository.deleteOrder(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                'Daftar Pesanan',
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Color(0xFF6366F1),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF6366F1),
                  unselectedLabelColor: Color(0xFF6B7280),
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'Semua'),
                    Tab(text: 'Menunggu'),
                    Tab(text: 'Proses'),
                    Tab(text: 'Selesai'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_getFilteredOrders('all'), currencyFormat),
                _buildOrderList(_getFilteredOrders('waiting'), currencyFormat),
                _buildOrderList(_getFilteredOrders('in_progress'), currencyFormat),
                _buildOrderList(_getFilteredOrders('done'), currencyFormat),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddOrder,
        icon: Icon(Icons.add),
        label: Text(
          'Tambah Pesanan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, NumberFormat currencyFormat) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada data pesanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToAddOrder,
              child: Text('Tambah Pesanan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToOrderDetail(order),
                  onLongPress: () {
                    if (order['status'] == 'waiting') {
                        _showStatusUpdateDialog(order);
                      }
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
                        SizedBox(height: 4),
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
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatusBadge(order['status']),
                            SizedBox(width: 8),
                            _buildPaymentBadge(order['is_paid']),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => Container(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.info, color: Color(0xFF6366F1)),
                                          title: Text(
                                            'Detail',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _navigateToOrderDetail(order);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.update, color: Color(0xFFF59E0B)),
                                          title: Text(
                                            'Ubah Status',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showStatusUpdateDialog(order);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.delete, color: Color(0xFFEF4444)),
                                          title: Text(
                                            'Hapus',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showDeleteConfirmationDialog(order);
                                          },
                                        ),
                          ],
                        ),
                                  ),
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
            ),
          );
        },
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
        color = Color(0xFF6B7280);
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

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Perbarui Status',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih status baru untuk pesanan ini:',
              style: GoogleFonts.poppins(),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                'Sedang Diproses',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.directions_car, color: Color(0xFF3B82F6)),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'in_progress');
              },
            ),
            ListTile(
              title: Text(
                'Selesai',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.check_circle, color: Color(0xFF10B981)),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'done');
              },
            ),
            ListTile(
              title: Text(
                'Dibatalkan',
                style: GoogleFonts.poppins(),
              ),
              leading: Icon(Icons.cancel, color: Color(0xFFEF4444)),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'cancelled');
              },
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.',
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
              _deleteOrder(order['id']);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
