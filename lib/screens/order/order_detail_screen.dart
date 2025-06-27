import 'package:flutter/material.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/repositories/payment_repository.dart';
import 'package:steam/models/payment.dart';
import 'package:steam/screens/order/order_form_screen.dart';
import 'package:steam/screens/payment/payment_form_screen.dart';
import 'package:steam/screens/receipt/receipt_screen.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  Map<String, dynamic>? _order;
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderRepository.getOrderWithDetails(widget.orderId);
      final payments = await _paymentRepository.getPaymentsByOrderId(widget.orderId);

      setState(() {
        _order = order;
        _payments = payments;
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

  Future<void> _navigateToEditOrder() async {
    if (_order == null) return;

    // First fetch the order data
    final orderData = await _orderRepository.getOrderById(widget.orderId);

    // Then navigate with the already fetched data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderFormScreen(
          order: orderData,
        ),
      ),
    );

    if (result != null && result) {
      _loadOrderDetails();
    }
  }

  Future<void> _navigateToAddPayment() async {
    if (_order == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFormScreen(orderId: widget.orderId),
      ),
    );

    if (result != null && result) {
      _loadOrderDetails();
    }
  }

  void _navigateToReceipt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(orderId: widget.orderId),
      ),
    );
  }

  Future<void> _updateOrderStatus(String status) async {
    try {
      await _orderRepository.updateOrderStatus(widget.orderId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrderDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePaymentStatus(int isPaid) async {
    try {
      await _orderRepository.updateOrderPaymentStatus(widget.orderId, isPaid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pembayaran berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrderDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteOrder() async {
    try {
      await _orderRepository.deleteOrder(widget.orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
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
        title: Text('Detail Pesanan'),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long),
            onPressed: _isLoading || _order == null ? null : _navigateToReceipt,
            tooltip: 'Lihat Struk',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _isLoading ? null : _navigateToEditOrder,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading ? null : _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _order == null
          ? Center(child: Text('Pesanan tidak ditemukan'))
          : SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pesanan #${_order!['id']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(_order!['status']),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Layanan', _order!['service_name']),
                    _buildInfoRow('Harga', currencyFormat.format(_order!['total_price'] ?? _order!['service_price'])),
                    _buildInfoRow('Tanggal', '${_order!['date']} ${_order!['time']}'),
                    _buildInfoRow(
                      'Pelanggan',
                      _order!['customer_name'] ?? 'Pelanggan umum',
                    ),
                    if (_order!['plate_number'] != null)
                      _buildInfoRow('Plat Nomor', _order!['plate_number']),
                    if (_order!['notes'] != null && _order!['notes'].toString().isNotEmpty)
                      _buildInfoRow('Catatan', _order!['notes']),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.payment),
                            label: Text('Bayar'),
                            onPressed: _order!['is_paid'] == 1
                                ? null
                                : _navigateToAddPayment,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.update),
                            label: Text('Status'),
                            onPressed: () => _showStatusUpdateDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_order!['is_paid'] == 1)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.receipt),
                            label: Text('Lihat Struk'),
                            onPressed: _navigateToReceipt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildPaymentBadge(_order!['is_paid']),
              ],
            ),
            SizedBox(height: 8),
            _payments.isEmpty
                ? Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Belum ada pembayaran'),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      currencyFormat.format(payment.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${payment.paymentDate}'),
                        Text('Metode: ${payment.method ?? 'Tunai'}'),
                        if (payment.note != null && payment.note!.isNotEmpty)
                          Text('Catatan: ${payment.note}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.receipt, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptScreen(
                                  orderId: widget.orderId,
                                  paymentId: payment.id,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeletePaymentConfirmationDialog(payment.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_order!['is_paid'] == 0)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: Text('Tandai Sudah Dibayar'),
                    onPressed: () => _updatePaymentStatus(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ),
            if (_order!['is_paid'] == 1)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Tandai Belum Dibayar'),
                    onPressed: () => _updatePaymentStatus(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
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
            width: 100,
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'waiting':
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'Diproses';
        break;
      case 'done':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Batal';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(int isPaid) {
    Color color = isPaid == 1 ? Colors.green : Colors.red;
    String text = isPaid == 1 ? 'Lunas' : 'Belum Bayar';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Perbarui Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih status baru untuk pesanan ini:'),
            SizedBox(height: 16),
            ListTile(
              title: Text('Menunggu'),
              leading: Icon(Icons.hourglass_empty, color: Colors.orange),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('waiting');
              },
            ),
            ListTile(
              title: Text('Sedang Diproses'),
              leading: Icon(Icons.directions_car, color: Colors.blue),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('in_progress');
              },
            ),
            ListTile(
              title: Text('Selesai'),
              leading: Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('done');
              },
            ),
            ListTile(
              title: Text('Dibatalkan'),
              leading: Icon(Icons.cancel, color: Colors.red),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('cancelled');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder();
            },
            child: Text('Hapus'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePaymentConfirmationDialog(int paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pembayaran ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePayment(paymentId);
            },
            child: Text('Hapus'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayment(int paymentId) async {
    try {
      await _paymentRepository.deletePayment(paymentId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrderDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
