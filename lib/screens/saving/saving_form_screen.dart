import 'package:flutter/material.dart';
import 'package:steam/models/saving.dart';
import 'package:steam/repositories/saving_repository.dart';
import 'package:intl/intl.dart';

class SavingFormScreen extends StatefulWidget {
  final Saving? saving;

  SavingFormScreen({this.saving});

  @override
  _SavingFormScreenState createState() => _SavingFormScreenState();
}

class _SavingFormScreenState extends State<SavingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final SavingRepository _savingRepository = SavingRepository();
  
  String _selectedType = 'deposit';
  DateTime _selectedDate = DateTime.now();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.saving != null) {
      _amountController.text = widget.saving!.amount.toString();
      _descriptionController.text = widget.saving!.description ?? '';
      _selectedType = widget.saving!.type;
      
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.saving!.date);
      } catch (e) {
        // Use current date if parsing fails
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSaving() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final saving = Saving(
        id: widget.saving?.id,
        type: _selectedType,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        description: _descriptionController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      if (widget.saving == null) {
        await _savingRepository.insertSaving(saving);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tabungan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _savingRepository.updateSaving(saving);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tabungan berhasil diperbarui'),
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
        title: Text(widget.saving == null ? 'Tambah Tabungan' : 'Edit Tabungan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'deposit',
                    label: Text('Setoran'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'withdrawal',
                    label: Text('Penarikan'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  try {
                    double.parse(value.replaceAll(',', '.'));
                  } catch (e) {
                    return 'Jumlah harus berupa angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              InkWell(
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
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSaving,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(widget.saving == null ? 'Tambah' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
