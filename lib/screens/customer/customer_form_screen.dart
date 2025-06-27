import 'package:flutter/material.dart';
import 'package:steam/models/customer.dart';
import 'package:steam/repositories/customer_repository.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  CustomerFormScreen({this.customer});

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _motorTypeController = TextEditingController();
  final _plateNumberController = TextEditingController();
  
  final CustomerRepository _customerRepository = CustomerRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _motorTypeController.text = widget.customer!.motorType ?? '';
      _plateNumberController.text = widget.customer!.plateNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _motorTypeController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        motorType: _motorTypeController.text.trim(),
        plateNumber: _plateNumberController.text.trim(),
      );

      if (widget.customer == null) {
        await _customerRepository.insertCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pelanggan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _customerRepository.updateCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pelanggan berhasil diperbarui'),
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pelanggan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _motorTypeController,
                decoration: InputDecoration(
                  labelText: 'Jenis Motor',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor Plat',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCustomer,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(widget.customer == null ? 'Tambah' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
