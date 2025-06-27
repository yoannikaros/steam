import 'package:flutter/material.dart';
import 'package:steam/models/customer.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  CustomerDetailScreen({required this.customer});

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Map<String, dynamic>> _customerOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerOrders();
  }

  Future<void> _loadCustomerOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allOrders = await _orderRepository.getOrdersWithDetails();
      final customerOrders = allOrders.where((order) => order['customer_id'] == widget.customer.id).toList();
      
      setState(() {
        _customerOrders = customerOrders;
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

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pelanggan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Nomor Telepon', widget.customer.phone ?? '-'),
                    _buildInfoRow('Jenis Motor', widget.customer.motorType ?? '-'),
                    _buildInfoRow('Nomor Plat', widget.customer.plateNumber ?? '-'),
                    _buildInfoRow('Terdaftar Pada', widget.customer.createdAt ?? '-'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Riwayat Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _customerOrders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Tidak ada riwayat pesanan'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _customerOrders.length,
                        itemBuilder: (context, index) {
                          final order = _customerOrders[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('${order['service_name']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal: ${order['date']} ${order['time']}'),
                                  Text('Status: ${_getStatusText(order['status'])}'),
                                ],
                              ),
                              trailing: Text(
                                currencyFormat.format(order['total_price'] ?? order['service_price']),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'done':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
