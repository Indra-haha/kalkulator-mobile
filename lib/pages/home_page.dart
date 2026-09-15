import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'kelompok_page.dart';
import 'login_page.dart';
import 'kalkulator_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.instance.getUser();
    if (user != null && mounted) {
      setState(() => _user = user);
    }
  }

  void _openPage(BuildContext context, Widget page, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: title),
      ),
    );
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    final token = await SessionService.instance.getToken();
    try {
      if (token != null) {
        // Hapus session di backend (token di-blacklist -> expired).
        await ApiService.instance.logout(token);
      }
    } catch (_) {
      // Backend tidak terjangkau; session lokal tetap dihapus.
    }
    await SessionService.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final String nama = (user?['nama'] as String?) ?? '';
    final String nim = (user?['nim'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _loggingOut ? null : _logout,
            icon: _loggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(
                  nama.isEmpty ? 'Selamat datang' : 'Halo, $nama',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                subtitle: nim.isEmpty ? null : Text('NIM: $nim'),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.group, color: Colors.deepPurple),
              title: const Text('Data Kelompok', style: TextStyle(fontSize: 16)),
              subtitle: const Text('Lihat data anggota kelompok', style: TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _openPage(context, const KelompokPage(), 'data-kelompok'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Colors.deepPurple),
              title: const Text('Kalkulator', style: TextStyle(fontSize: 16)),
              subtitle: const Text('Operasi matematika', style: TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _openPage(context, const KalkulatorPage(), 'kalkulator'),
            ),
          ),
        ],
      ),
    );
  }
}