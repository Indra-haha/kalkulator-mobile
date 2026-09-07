import 'package:flutter/material.dart';

import 'kalkulator_page.dart';
import 'kelompok_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPage(BuildContext context, Widget page, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.group, color: Colors.deepPurple),
              title: const Text('Data Kelompok'),
              subtitle: const Text('Lihat data anggota kelompok'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _openPage(context, const KelompokPage(), 'data-kelompok'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Colors.deepPurple),
              title: const Text('Penjumlahan & Pengurangan'),
              subtitle: const Text('Operasi + dan -'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openPage(
                context,
                const KalkulatorPage(initialOperation: 'penjumlahan'),
                'penjumlahan-pengurangan',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.functions, color: Colors.deepPurple),
              title: const Text('Perkalian & Pembagian'),
              subtitle: const Text('Operasi * dan /'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openPage(
                context,
                const KalkulatorPage(initialOperation: 'perkalian'),
                'perkalian-pembagian',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
