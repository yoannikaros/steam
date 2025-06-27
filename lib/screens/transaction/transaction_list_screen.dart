import 'package:flutter/material.dart';
import 'package:steam/models/transaction.dart';
import 'package:steam/repositories/transaction_repository.dart';
import 'package:steam/screens/transaction/transaction_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionListScreen extends StatefulWidget {
  final bool showAddForm;

  TransactionListScreen({this.showAddForm = false});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> with SingleTickerProviderStateMixin {
  final TransactionRepository _transactionRepository = TransactionRepository();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
    
    if (widget.showAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAddTransaction();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionRepository.getAllTransactions();
      setState(() {
        _transactions = transactions;
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

  List<Transaction> _getFilteredTransactions(String type) {
    if (type == 'all') {
      return _transactions;
    }
    return _transactions.where((transaction) => transaction.type == type).toList();
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(),
      ),
    );

    if (result != null && result) {
      _loadTransactions();
    }
  }

  Future<void> _navigateToEditTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );

    if (result != null && result) {
      _loadTransactions();
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await _transactionRepository.deleteTransaction(transaction.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadTransactions();
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
        title: Text('Daftar Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Semua'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_getFilteredTransactions('all'), currencyFormat),
                _buildTransactionList(_getFilteredTransactions('income'), currencyFormat),
                _buildTransactionList(_getFilteredTransactions('expense'), currencyFormat),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions, NumberFormat currencyFormat) {
    if (transactions.isEmpty) {
      return Center(child: Text('Tidak ada data transaksi'));
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: transaction.type == 'income'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      transaction.type == 'income'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: transaction.type == 'income' ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.category ?? (transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran'),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              transaction.transactionDate,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            transaction.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(transaction.amount),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: transaction.type == 'income' ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _navigateToEditTransaction(transaction),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteTransaction(transaction);
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
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
