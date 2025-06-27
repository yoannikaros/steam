import 'package:flutter/material.dart';
import 'package:steam/models/saving.dart';
import 'package:steam/repositories/saving_repository.dart';
import 'package:steam/screens/saving/saving_form_screen.dart';
import 'package:intl/intl.dart';

class SavingListScreen extends StatefulWidget {
  @override
  _SavingListScreenState createState() => _SavingListScreenState();
}

class _SavingListScreenState extends State<SavingListScreen> with SingleTickerProviderStateMixin {
  final SavingRepository _savingRepository = SavingRepository();
  List<Saving> _savings = [];
  double _totalSavings = 0;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final savings = await _savingRepository.getAllSavings();
      final totalSavings = await _savingRepository.getTotalSavings();
      
      setState(() {
        _savings = savings;
        _totalSavings = totalSavings;
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

  List<Saving> _getFilteredSavings(String type) {
    if (type == 'all') {
      return _savings;
    }
    return _savings.where((saving) => saving.type == type).toList();
  }

  Future<void> _navigateToAddSaving() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavingFormScreen(),
      ),
    );

    if (result != null && result) {
      _loadSavings();
    }
  }

  Future<void> _navigateToEditSaving(Saving saving) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavingFormScreen(saving: saving),
      ),
    );

    if (result != null && result) {
      _loadSavings();
    }
  }

  Future<void> _deleteSaving(Saving saving) async {
    try {
      await _savingRepository.deleteSaving(saving.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tabungan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSavings();
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
        title: Text('Tabungan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Semua'),
            Tab(text: 'Setoran'),
            Tab(text: 'Penarikan'),
          ],
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.savings,
                    size: 48,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Tabungan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currencyFormat.format(_totalSavings),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _totalSavings >= 0 ? Colors.blue : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSavingList(_getFilteredSavings('all'), currencyFormat),
                      _buildSavingList(_getFilteredSavings('deposit'), currencyFormat),
                      _buildSavingList(_getFilteredSavings('withdrawal'), currencyFormat),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSaving,
        child: Icon(Icons.add),
        tooltip: 'Tambah Tabungan',
      ),
    );
  }

  Widget _buildSavingList(List<Saving> savings, NumberFormat currencyFormat) {
    if (savings.isEmpty) {
      return Center(child: Text('Tidak ada data tabungan'));
    }

    return RefreshIndicator(
      onRefresh: _loadSavings,
      child: ListView.builder(
        itemCount: savings.length,
        itemBuilder: (context, index) {
          final saving = savings[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: saving.type == 'deposit'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                child: Icon(
                  saving.type == 'deposit'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: saving.type == 'deposit' ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                saving.type == 'deposit' ? 'Setoran' : 'Penarikan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal: ${saving.date}'),
                  if (saving.description != null && saving.description!.isNotEmpty)
                    Text(
                      saving.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencyFormat.format(saving.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: saving.type == 'deposit' ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToEditSaving(saving),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Konfirmasi'),
                          content: Text('Apakah Anda yakin ingin menghapus data tabungan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteSaving(saving);
                              },
                              child: Text('Hapus'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              isThreeLine: saving.description != null && saving.description!.isNotEmpty,
            ),
          );
        },
      ),
    );
  }
}
