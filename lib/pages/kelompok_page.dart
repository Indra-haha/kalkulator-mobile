import 'package:flutter/material.dart';

import '../models/anggota.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_page.dart';

class KelompokPage extends StatefulWidget {
  const KelompokPage({super.key});

  @override
  State<KelompokPage> createState() => _KelompokPageState();
}

class _KelompokPageState extends State<KelompokPage> {
  List<Anggota> _anggota = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await SessionService.instance.getToken();
    if (token == null) {
      _goToLogin();
      return;
    }

    try {
      final data = await ApiService.instance.getAnggota(token);
      if (!mounted) return;
      setState(() {
        _anggota = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await SessionService.instance.clear();
        _goToLogin();
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Tidak dapat terhubung ke server.';
        _loading = false;
      });
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kelompok'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _anggota.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final data = _anggota[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(
              data.nama,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
            subtitle: Text(
              '${data.nim} - ${data.kelas}',
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}