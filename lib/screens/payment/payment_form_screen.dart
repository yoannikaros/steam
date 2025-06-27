import 'package:flutter/material.dart';
import 'package:steam/models/payment.dart';
import 'package:steam/repositories/payment_repository.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:steam/screens/receipt/receipt_screen.dart';
import 'package:intl/intl.dart';

class PaymentFormScreen extends StatefulWidget {
  final int orderId;
  final Payment? payment;

  PaymentFormScreen({required this.orderId, this.payment});

  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  final PaymentRepository _paymentRepository = PaymentRepository();
  final OrderRepository _orderRepository = OrderRepository();
  
  String _selectedMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _order;
  
  bool _isLoading = true;
  bool _isSaving = false;
  int? _savedPaymentId;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    
    if (widget.payment != null) {
      _amountController.text = widget.payment!.amount.toString();
      _noteController.text = widget.payment!.note ?? '';
      _selectedMethod = widget.payment!.method ?? 'cash';
      
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.payment!.paymentDate);
      } catch (e) {
        // Use current date if parsing fails
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderRepository.getOrderWithDetails(widget.orderId);
      
      setState(() {
        _order = order;
        _isLoading = false;
      });
      
      if (widget.payment == null && order != null) {
        _amountController.text = (order['total_price'] ?? order['service_price']).toString();
      }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final payment = Payment(
        id: widget.payment?.id,
        orderId: widget.orderId,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        method: _selectedMethod,
        paymentDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        note: _noteController.text.trim(),
      );

      int paymentId;
      if (widget.payment == null) {
        paymentId = await _paymentRepository.insertPayment(payment);
        await _orderRepository.updateOrderPaymentStatus(widget.orderId, 1);
        setState(() {
          _savedPaymentId = paymentId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _paymentRepository.updatePayment(payment);
        setState(() {
          _savedPaymentId = payment.id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _showReceiptOptions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showReceiptOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran Berhasil'),
        content: Text('Apakah Anda ingin melihat struk pembayaran?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToReceipt();
            },
            child: Text('Lihat Struk'),
          ),
        ],
      ),
    );
  }

  void _navigateToReceipt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          orderId: widget.orderId,
          paymentId: _savedPaymentId,
        ),
      ),
    ).then((_) {
      Navigator.pop(context, true);
    });
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
        title: Text(widget.payment == null ? 'Tambah Pembayaran' : 'Edit Pembayaran'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text('Pesanan tidak ditemukan'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detail Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow('Layanan', _order!['service_name']),
                                _buildInfoRow('Harga', currencyFormat.format(_order!['total_price'] ?? _order!['service_price'])),
                                _buildInfoRow('Tanggal', '${_order!['date']} ${_order!['time']}'),
                                _buildInfoRow(
                                  'Pelanggan',
                                  _order!['customer_name'] ?? 'Pelanggan umum',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Pembayaran',
                            border: OutlineInputBorder(),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah pembayaran tidak boleh kosong';
                            }
                            try {
                              double.parse(value.replaceAll(',', '.'));
                            } catch (e) {
                              return 'Jumlah pembayaran harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Metode Pembayaran',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedMethod,
                          items: [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Tunai'),
                            ),
                            DropdownMenuItem(
                              value: 'transfer',
                              child: Text('Transfer Bank'),
                            ),
                            DropdownMenuItem(
                              value: 'qris',
                              child: Text('QRIS'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Lainnya'),
                            ),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedMethod = value ?? 'cash';
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Tanggal Pembayaran',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Catatan',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _savePayment,
                            child: _isSaving
                                ? CircularProgressIndicator()
                                : Text(widget.payment == null ? 'Tambah' : 'Simpan'),
                          ),
                        ),
                      ],
                    ),
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
}
