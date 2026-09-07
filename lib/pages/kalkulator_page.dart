import 'package:flutter/material.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key, this.initialOperation = 'penjumlahan'});

  final String initialOperation;

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final TextEditingController _angka1Controller = TextEditingController();
  final TextEditingController _angka2Controller = TextEditingController();

  late final Map<String, OperationInfo> _operations;
  late String _operation;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _operations = {
      'penjumlahan': const OperationInfo('Penjumlahan', '+', '+'),
      'pengurangan': const OperationInfo('Pengurangan', '-', '-'),
      'perkalian': const OperationInfo('Perkalian', '*', '\u00d7'),
      'pembagian': const OperationInfo('Pembagian', '/', '\u00f7'),
    };
    _operation = widget.initialOperation;
  }

  void _hitung() {
    final double? a = double.tryParse(_angka1Controller.text.trim());
    final double? b = double.tryParse(_angka2Controller.text.trim());

    if (a == null || b == null) {
      setState(() {
        _result = 'Masukkan angka yang valid!';
      });
      return;
    }

    if (b == 0 && _operation == 'pembagian') {
      setState(() {
        _result = 'Tidak dapat membagi dengan nol!';
      });
      return;
    }

    final double hasil = switch (_operation) {
      'penjumlahan' => a + b,
      'pengurangan' => a - b,
      'perkalian' => a * b,
      'pembagian' => a / b,
      _ => 0,
    };

    setState(() {
      _result =
          '$a ${_operations[_operation]!.simbol} $b = ${_numFormat(hasil)}';
    });
  }

  String _numFormat(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  void _clear() {
    _angka1Controller.clear();
    _angka2Controller.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OperationInfo info = _operations[_operation]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(info.nama),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: _operations.entries
                  .where((e) =>
                      _isTambahKurang(_operation)
                          ? e.key == 'penjumlahan' || e.key == 'pengurangan'
                          : e.key == 'perkalian' || e.key == 'pembagian')
                  .map(
                (entry) => ButtonSegment<String>(
                  value: entry.key,
                  label: Text(entry.value.simbolTab),
                ),
              ).toList(),
              selected: {_operation},
              onSelectionChanged: (selection) {
                setState(() {
                  _operation = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _angka1Controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Angka 1',
                prefixIcon: Icon(Icons.pin_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              info.simbolTab,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _angka2Controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Angka 2',
                prefixIcon: Icon(Icons.pin_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hitung,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hitung'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Bersihkan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hasil: $_result',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isTambahKurang(String op) {
    return op == 'penjumlahan' || op == 'pengurangan';
  }
}

class OperationInfo {
  const OperationInfo(this.nama, this.simbol, this.simbolTab);

  final String nama;
  final String simbol;
  final String simbolTab;
}