import 'package:flutter/material.dart';

class KelompokPage extends StatelessWidget {
  const KelompokPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> anggota = [
      {
        'nama': 'Andi Pratama',
        'nim': '2023001',
        'kelas': 'TI-3A',
      },
      {
        'nama': 'Budi Santoso',
        'nim': '2023002',
        'kelas': 'TI-3A',
      },
      {
        'nama': 'Citra Lestari',
        'nim': '2023003',
        'kelas': 'TI-3A',
      },
      {
        'nama': 'Dewi Anggraini',
        'nim': '2023004',
        'kelas': 'TI-3A',
      },
      {
        'nama': 'Eko Ramadhan',
        'nim': '2023005',
        'kelas': 'TI-3A',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kelompok'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: anggota.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final data = anggota[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              title: Text(data['nama']!),
              subtitle: Text('${data['nim']} - ${data['kelas']}'),
            ),
          );
        },
      ),
    );
  }
}