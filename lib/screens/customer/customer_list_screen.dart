import 'package:flutter/material.dart';
import 'package:steam/models/customer.dart';
import 'package:steam/repositories/customer_repository.dart';
import 'package:steam/screens/customer/customer_form_screen.dart';
import 'package:steam/screens/customer/customer_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerListScreen extends StatefulWidget {
  final bool showAddForm;

  CustomerListScreen({this.showAddForm = false});

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> with SingleTickerProviderStateMixin {
  final CustomerRepository _customerRepository = CustomerRepository();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    if (widget.showAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAddCustomer();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _customerRepository.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
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

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = _customers;
      });
    } else {
      setState(() {
        _filteredCustomers = _customers.where((customer) {
          return customer.name.toLowerCase().contains(query.toLowerCase()) ||
              (customer.phone != null && customer.phone!.contains(query)) ||
              (customer.plateNumber != null && customer.plateNumber!.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      });
    }
  }

  Future<void> _navigateToAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFormScreen(),
      ),
    );

    if (result != null && result) {
      _loadCustomers();
    }
  }

  Future<void> _navigateToEditCustomer(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFormScreen(customer: customer),
      ),
    );

    if (result != null && result) {
      _loadCustomers();
    }
  }

  Future<void> _navigateToCustomerDetail(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );

    if (result != null && result) {
      _loadCustomers();
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    try {
      await _customerRepository.deleteCustomer(customer.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelanggan berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadCustomers();
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
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Daftar Pelanggan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
              controller: _searchController,
              decoration: InputDecoration(
                    hintText: 'Cari nama, nomor telepon, atau plat nomor...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6366F1)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                            icon: Icon(Icons.clear, color: Color(0xFF6B7280)),
                        onPressed: () {
                          _searchController.clear();
                          _filterCustomers('');
                        },
                      )
                    : null,
                    filled: true,
                    fillColor: Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
              onChanged: _filterCustomers,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_filteredCustomers.length} Pelanggan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  )
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada pelanggan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambahkan pelanggan baru untuk memulai',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          onRefresh: _loadCustomers,
                          color: Color(0xFF6366F1),
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                              return Container(
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
                                    onTap: () => _navigateToCustomerDetail(customer),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Color(0xFF6366F1).withOpacity(0.1),
                                                child: Text(
                                                  customer.name[0].toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                    color: Color(0xFF6366F1),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      customer.name,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF1F2937),
                                                      ),
                                                    ),
                                                    if (customer.phone != null && customer.phone!.isNotEmpty)
                                                      Text(
                                                        customer.phone!,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Color(0xFF6B7280),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                              ),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, color: Color(0xFF6366F1), size: 20),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Edit',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            color: Color(0xFF1F2937),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                children: [
                                                        Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Hapus',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            color: Color(0xFF1F2937),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _navigateToEditCustomer(customer);
                                                  } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                                        title: Text(
                                                          'Konfirmasi',
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        content: Text(
                                                          'Apakah Anda yakin ingin menghapus pelanggan ini?',
                                                          style: GoogleFonts.poppins(),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                                            child: Text(
                                                              'Batal',
                                                              style: GoogleFonts.poppins(
                                                                color: Color(0xFF6B7280),
                                                              ),
                                                            ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteCustomer(customer);
                                              },
                                                            child: Text(
                                                              'Hapus',
                                                              style: GoogleFonts.poppins(
                                                                color: Color(0xFFEF4444),
                                                              ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                                  }
                                    },
                                  ),
                                ],
                              ),
                                          if (customer.plateNumber != null && customer.plateNumber!.isNotEmpty ||
                                              customer.motorType != null && customer.motorType!.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 12),
                                              child: Row(
                                                children: [
                                                  if (customer.plateNumber != null && customer.plateNumber!.isNotEmpty)
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF6366F1).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        customer.plateNumber!,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: Color(0xFF6366F1),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  if (customer.motorType != null && customer.motorType!.isNotEmpty)
                                                    Container(
                                                      margin: EdgeInsets.only(left: 8),
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF10B981).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        customer.motorType!,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: Color(0xFF10B981),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        },
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddCustomer,
        icon: Icon(Icons.add),
        label: Text(
          'Tambah Pelanggan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        elevation: 4,
      ),
    );
  }
}
