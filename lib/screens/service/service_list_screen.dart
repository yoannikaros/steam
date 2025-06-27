import 'package:flutter/material.dart';
import 'package:steam/models/service.dart';
import 'package:steam/repositories/service_repository.dart';
import 'package:steam/screens/service/service_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> with SingleTickerProviderStateMixin {
  final ServiceRepository _serviceRepository = ServiceRepository();
  List<Service> _services = [];
  List<Service> _filteredServices = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _serviceRepository.getAllServices();
      setState(() {
        _services = services;
        _filteredServices = services;
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

  void _filterServices(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _services;
      });
    } else {
      setState(() {
        _filteredServices = _services.where((service) {
          return service.name.toLowerCase().contains(query.toLowerCase()) ||
              (service.description != null && service.description!.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      });
    }
  }

  Future<void> _navigateToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(),
      ),
    );

    if (result != null && result) {
      _loadServices();
    }
  }

  Future<void> _navigateToEditService(Service service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(service: service),
      ),
    );

    if (result != null && result) {
      _loadServices();
    }
  }

  Future<void> _deleteService(Service service) async {
    try {
      await _serviceRepository.deleteService(service.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Layanan berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadServices();
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
                  'Daftar Layanan',
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                          children: [
                        Icon(Icons.search, color: Color(0xFF6366F1)),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterServices,
                            decoration: InputDecoration(
                              hintText: 'Cari layanan...',
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.poppins(
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: Color(0xFF6B7280)),
                            onPressed: () {
                              _searchController.clear();
                              _filterServices('');
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ${_filteredServices.length} Layanan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _loadServices,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Refresh'),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: _isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredServices.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cleaning_services_outlined,
                                size: 64,
                                color: Color(0xFF9CA3AF),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada data layanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _navigateToAddService,
                                child: Text('Tambah Layanan'),
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
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = _filteredServices[index];
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
                                    onTap: () => _navigateToEditService(service),
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
                                                  service.name,
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
                                                  currencyFormat.format(service.price),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF6366F1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (service.description != null && service.description!.isNotEmpty) ...[
                                            SizedBox(height: 8),
                                            Text(
                                              service.description!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                            IconButton(
                                                icon: Icon(Icons.edit, color: Color(0xFF6366F1)),
                              onPressed: () => _navigateToEditService(service),
                                                tooltip: 'Edit',
                            ),
                            IconButton(
                                                icon: Icon(Icons.delete, color: Color(0xFFEF4444)),
                              onPressed: () {
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
                                                        'Apakah Anda yakin ingin menghapus layanan ini?',
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
                                          _deleteService(service);
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
                              },
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
                          childCount: _filteredServices.length,
                        ),
                      ),
          ),
        ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddService,
        icon: Icon(Icons.add),
        label: Text(
          'Tambah Layanan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }
}
