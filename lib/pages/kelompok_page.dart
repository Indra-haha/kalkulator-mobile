import 'package:flutter/material.dart';

class KelompokPage extends StatelessWidget {
  const KelompokPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> anggota = [
      {
        'nama': 'Pranata Raplialiano',
        'nim': '124240175',
        'kelas': 'Pemrograman Mobile SI-B',
      },
      {
        'nama': 'Indra Suryanto P',
        'nim': '124240180',
        'kelas': 'Pemrograman Mobile SI-B',
      },
      {
        'nama': 'Fajar Sidiq H',
        'nim': '124240183',
        'kelas': 'Pemrograman Mobile SI-B',
      },
      {
        'nama': 'Aditya Rahmat F',
        'nim': '124240184',
        'kelas': 'Pemrograman Mobile SI-B',
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