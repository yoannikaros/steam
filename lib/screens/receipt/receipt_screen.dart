import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/repositories/payment_repository.dart';
import 'package:steam/repositories/setting_repository.dart';
import 'package:steam/models/payment.dart';
import 'package:steam/models/setting.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReceiptScreen extends StatefulWidget {
  final int orderId;
  final int? paymentId;

  ReceiptScreen({required this.orderId, this.paymentId});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final SettingRepository _settingRepository = SettingRepository();
  
  Map<String, dynamic>? _order;
  List<Payment> _payments = [];
  Setting? _setting;
  bool _isLoading = true;
  
  final GlobalKey _receiptKey = GlobalKey();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _loadReceiptData();
  }

  Future<void> _loadReceiptData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderRepository.getOrderWithDetails(widget.orderId);
      List<Payment> payments;
      
      if (widget.paymentId != null) {
        final payment = await _paymentRepository.getPaymentById(widget.paymentId!);
        payments = payment != null ? [payment] : [];
      } else {
        payments = await _paymentRepository.getPaymentsByOrderId(widget.orderId);
      }
      
      final setting = await _settingRepository.getSettings();
      
      setState(() {
        _order = order;
        _payments = payments;
        _setting = setting;
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

  Future<void> _captureAndShareReceipt() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/receipt.png').create();
        await file.writeAsBytes(pngBytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Struk Pembayaran ${_setting?.businessName ?? 'Cuci Motor'}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan struk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Struk Pembayaran'),
        actions: [
          if (!_isLoading && !_isCapturing)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _captureAndShareReceipt,
              tooltip: 'Bagikan Struk',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text('Data pesanan tidak ditemukan'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _receiptKey,
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _setting?.businessName ?? 'Cuci Motor',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Divider(thickness: 2),
                              SizedBox(height: 8),
                              if (_setting?.noteHeader != null && _setting!.noteHeader!.isNotEmpty)
                                Text(
                                  _setting!.noteHeader!,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              SizedBox(height: 16),
                              _buildReceiptInfo('No. Pesanan', '#${_order!['id']}'),
                              _buildReceiptInfo('Tanggal', '${_order!['date']} ${_order!['time']}'),
                              _buildReceiptInfo('Pelanggan', _order!['customer_name'] ?? 'Pelanggan Umum'),
                              if (_order!['plate_number'] != null)
                                _buildReceiptInfo('Plat Nomor', _order!['plate_number']),
                              SizedBox(height: 16),
                              Divider(),
                              SizedBox(height: 8),
                              _buildReceiptItem(
                                'Layanan',
                                _order!['service_name'],
                                _formatCurrency(_order!['service_price']),
                              ),
                              Divider(),
                              _buildReceiptTotal(
                                'Total',
                                _formatCurrency(_order!['total_price'] ?? _order!['service_price']),
                              ),
                              SizedBox(height: 16),
                              Divider(),
                              SizedBox(height: 8),
                              Text(
                                'Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (_payments.isEmpty)
                                Text('Belum ada pembayaran')
                              else
                                Column(
                                  children: _payments.map((payment) {
                                    return _buildReceiptPayment(
                                      payment.paymentDate,
                                      payment.method ?? 'Tunai',
                                      _formatCurrency(payment.amount),
                                    );
                                  }).toList(),
                                ),
                              SizedBox(height: 16),
                              _buildReceiptStatus(
                                'Status Pembayaran',
                                _order!['is_paid'] == 1 ? 'LUNAS' : 'BELUM LUNAS',
                                _order!['is_paid'] == 1 ? Colors.green : Colors.red,
                              ),
                              SizedBox(height: 16),
                              if (_setting?.noteFooter != null && _setting!.noteFooter!.isNotEmpty)
                                Text(
                                  _setting!.noteFooter!,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              SizedBox(height: 8),
                              Divider(thickness: 2),
                              SizedBox(height: 8),
                              Text(
                                'Terima Kasih',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Screenshot struk ini sebagai bukti pembayaran',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isCapturing ? null : _captureAndShareReceipt,
                        icon: Icon(Icons.share),
                        label: Text(_isCapturing ? 'Memproses...' : 'Bagikan Struk'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReceiptInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildReceiptItem(String name, String description, String price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(price),
            ],
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTotal(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPayment(String date, String method, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date),
                Text(
                  method,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptStatus(String label, String status, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
      alignment: Alignment.center,
    );
  }

  String _formatCurrency(dynamic amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }
}
