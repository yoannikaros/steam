import 'package:flutter/material.dart';
import 'package:steam/models/user.dart';
import 'package:steam/repositories/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:steam/providers/auth_provider.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserRepository _userRepository = UserRepository();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userRepository.getAllUsers();
      setState(() {
        _users = users;
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

  void _showAddUserDialog() {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    String _selectedRole = 'admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Peran',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'kasir',
                    child: Text('Kasir'),
                  ),
                  DropdownMenuItem(
                    value: 'operator',
                    child: Text('Operator'),
                  ),
                ],
                onChanged: (String? value) {
                  _selectedRole = value ?? 'admin';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username dan password tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final user = User(
                username: _usernameController.text.trim(),
                password: _passwordController.text.trim(),
                role: _selectedRole,
              );

              try {
                await _userRepository.insertUser(user);
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengguna berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final _usernameController = TextEditingController(text: user.username);
    final _passwordController = TextEditingController();
    String? _selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Username tidak bisa diubah
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru (kosongkan jika tidak diubah)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Peran',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'kasir',
                    child: Text('Kasir'),
                  ),
                  DropdownMenuItem(
                    value: 'operator',
                    child: Text('Operator'),
                  ),
                ],
                onChanged: (String? value) {
                  _selectedRole = value ?? 'admin';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = User(
                id: user.id,
                username: user.username,
                password: _passwordController.text.isEmpty ? user.password : _passwordController.text.trim(),
                role: _selectedRole,
              );

              try {
                await _userRepository.updateUser(updatedUser);
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengguna berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    if (currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda tidak dapat menghapus akun yang sedang digunakan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _userRepository.deleteUser(user.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(child: Text('Tidak ada data pengguna'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user.username),
                        subtitle: Text('Peran: ${_getRoleText(user.role)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditUserDialog(user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Konfirmasi'),
                                    content: Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteUser(user);
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
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah Pengguna',
      ),
    );
  }

  String _getRoleText(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'kasir':
        return 'Kasir';
      case 'operator':
        return 'Operator';
      default:
        return role ?? 'Admin';
    }
  }
}
