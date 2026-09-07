import 'package:flutter/material.dart';

class JumlahTotalPage extends StatefulWidget {
  const JumlahTotalPage({super.key});

  @override
  State<JumlahTotalPage> createState() => _JumlahTotalPageState();
}

class _JumlahTotalPageState extends State<JumlahTotalPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String _detail = '';

  void _hitung() {
    final String input = _inputController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _result = '';
        _detail = 'Input tidak boleh kosong!';
      });
      return;
    }

    int total = 0;
    final List<String> digitList = input.split('').where((c) {
      return int.tryParse(c) != null;
    }).toList();

    if (digitList.isEmpty) {
      setState(() {
        _result = '';
        _detail = 'Tidak ada angka yang ditemukan pada input!';
      });
      return;
    }

    for (final String digit in digitList) {
      total += int.parse(digit);
    }

    setState(() {
      _detail = '${digitList.join(' + ')} = $total';
      _result = 'Total: $total';
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jumlah Total Angka'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan data angka, kemudian total seluruh angka akan dihitung.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Input data',
                prefixIcon: Icon(Icons.data_object),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hitung,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Hitung Total'),
            ),
            const SizedBox(height: 24),
            if (_detail.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _detail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
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