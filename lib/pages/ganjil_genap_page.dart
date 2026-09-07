import 'package:flutter/material.dart';

class GanjilGenapPage extends StatefulWidget {
  const GanjilGenapPage({super.key});

  @override
  State<GanjilGenapPage> createState() => _GanjilGenapPageState();
}

class _GanjilGenapPageState extends State<GanjilGenapPage> {
  final TextEditingController _bilanganController = TextEditingController();
  String _result = '';

  void _cek() {
    final int? angka = int.tryParse(_bilanganController.text.trim());

    if (angka == null) {
      setState(() {
        _result = 'Masukkan bilangan bulat yang valid!';
      });
      return;
    }

    setState(() {
      _result = angka.isEven ? 'Genap' : 'Ganjil';
    });
  }

  @override
  void dispose() {
    _bilanganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Ganjil / Genap'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _bilanganController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masukkan bilangan',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cek,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cek Bilangan'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text('Bilangan tersebut termasuk:'),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}