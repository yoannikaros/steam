import 'package:flutter/material.dart';
import 'package:steam/models/customer.dart';
import 'package:steam/models/service.dart';
import 'package:steam/models/order.dart';
import 'package:steam/repositories/customer_repository.dart';
import 'package:steam/repositories/service_repository.dart';
import 'package:steam/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;

  OrderFormScreen({this.order});

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerRepository _customerRepository = CustomerRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  final OrderRepository _orderRepository = OrderRepository();
  
  List<Customer> _customers = [];
  List<Service> _services = [];
  
  Customer? _selectedCustomer;
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _notesController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _customerRepository.getAllCustomers();
      final services = await _serviceRepository.getAllServices();
      
      setState(() {
        _customers = customers;
        _services = services;
        _isLoading = false;
      });
      
      if (widget.order != null) {
        _loadOrderDetails();
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

  Future<void> _loadOrderDetails() async {
    try {
      if (widget.order!.customerId != null) {
        final customer = await _customerRepository.getCustomerById(widget.order!.customerId!);
        if (customer != null) {
          setState(() {
            _selectedCustomer = customer;
          });
        }
      }
      
      final service = await _serviceRepository.getServiceById(widget.order!.serviceId);
      if (service != null) {
        setState(() {
          _selectedService = service;
        });
      }
      
      final dateParts = widget.order!.date.split('-');
      final timeParts = widget.order!.time.split(':');
      
      setState(() {
        _selectedDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        _notesController.text = widget.order!.notes ?? '';
      });
    } catch (e) {
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
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih layanan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timeFormat = DateFormat('HH:mm');
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final order = Order(
        id: widget.order?.id,
        customerId: _selectedCustomer?.id,
        serviceId: _selectedService!.id!,
        date: dateFormat.format(_selectedDate),
        time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        totalPrice: _selectedService!.price,
        status: widget.order?.status ?? 'waiting',
        isPaid: widget.order?.isPaid ?? 0,
        notes: _notesController.text.trim(),
      );

      if (widget.order == null) {
        await _orderRepository.insertOrder(order);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _orderRepository.updateOrder(order);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
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
        title: Text(widget.order == null ? 'Tambah Pesanan' : 'Edit Pesanan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Customer>(
                      decoration: InputDecoration(
                        labelText: 'Pelanggan (Opsional)',
                        border: OutlineInputBorder(),
                        suffixIcon: _selectedCustomer != null
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedCustomer = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      hint: Text('Pilih Pelanggan'),
                      value: _selectedCustomer,
                      items: [
                        ..._customers.map((customer) {
                          return DropdownMenuItem<Customer>(
                            value: customer,
                            child: Text('${customer.name} ${customer.plateNumber != null ? '(${customer.plateNumber})' : ''}'),
                          );
                        }).toList(),
                      ],
                      onChanged: (Customer? value) {
                        setState(() {
                          _selectedCustomer = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<Service>(
                      decoration: InputDecoration(
                        labelText: 'Layanan',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text('Pilih Layanan'),
                      value: _selectedService,
                      items: _services.map((service) {
                        return DropdownMenuItem<Service>(
                          value: service,
                          child: Text('${service.name} (${currencyFormat.format(service.price)})'),
                        );
                      }).toList(),
                      onChanged: (Service? value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih layanan terlebih dahulu';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal',
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
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Waktu',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                                  Icon(Icons.access_time),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
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
                        onPressed: _isSaving ? null : _saveOrder,
                        child: _isSaving
                            ? CircularProgressIndicator()
                            : Text(widget.order == null ? 'Tambah' : 'Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
