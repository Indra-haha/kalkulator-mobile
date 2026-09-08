import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KalkulatorPage(),
  ));
}

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key, this.initialOperation = 'penjumlahan'});

  final String initialOperation;

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final TextEditingController _displayController = TextEditingController();

  late final Map<String, OperationInfo> _operations;
  late String _operation;
  String _result = '';

  final List<String> _gridButtons = [
    'C', '⌫','G/G', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', 'Deret', '=',
  ];

  @override
  void initState() {
    super.initState();
    _operations = {
      'penjumlahan': const OperationInfo('Penjumlahan', '+', '+'),
      'pengurangan': const OperationInfo('Pengurangan', '-', '-'),
      'perkalian': const OperationInfo('Perkalian', '*', '×'),
      'pembagian': const OperationInfo('Pembagian', '/', '÷'),
      'ganjil_genap': const OperationInfo('Ganjil / Genap', 'G/G', 'G/G'),
      'deret': const OperationInfo('Hitung Deret Data', 'Σ', 'Deret'),
    };
    _operation = widget.initialOperation;
  }

  void _onGridButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _clear();
        return;
      }
      if (value == '⌫') {
        if (_displayController.text.isNotEmpty) {
          _displayController.text =
              _displayController.text.substring(0, _displayController.text.length - 1);
        }
        return;
      }
      if (value == '=') {
        _hitung();
        return;
      }

      switch (value) {
        case '+':
          _operation = 'penjumlahan';
          _displayController.text += ' + ';
          return;
        case '-':
          _operation = 'pengurangan';
          _displayController.text += ' - ';
          return;
        case '×':
          _operation = 'perkalian';
          _displayController.text += ' × ';
          return;
        case '÷':
          _operation = 'pembagian';
          _displayController.text += ' ÷ ';
          return;
        case 'G/G':
          _operation = 'ganjil_genap';
          return;
        case 'Deret':
          _operation = 'deret';
          return;
      }

      _displayController.text += value;
    });
  }

  void _hitung() {
    final String raw = _displayController.text.trim();
    if (raw.isEmpty) return;

    if (_operation == 'ganjil_genap') {
      final int? num = int.tryParse(raw);
      if (num == null) {
        setState(() => _result = 'Masukkan angka bulat!');
        return;
      }
      setState(() {
        _result =
            '$num adalah Bilangan ${num % 2 == 0 ? "GENAP" : "GANJIL"}';
      });
      return;
    }

    if (_operation == 'deret') {
      final List<String> items = raw.split(RegExp(r'[,\s]+'));
      double total = 0;
      int count = 0;
      for (var item in items) {
        double? val = double.tryParse(item);
        if (val != null) {
          total += val;
          count++;
        }
      }
      setState(() {
        _result = count > 0
            ? 'Total $count data deret = ${_numFormat(total)}'
            : 'Tidak ada data valid';
      });
      return;
    }

    final List<String> parts = raw.split(RegExp(r'\s+[+\-×÷]\s+'));
    if (parts.length < 2) {
      setState(() => _result = 'Masukkan angka yang valid!');
      return;
    }

    final double? a = double.tryParse(parts[0].trim());
    final double? b = double.tryParse(parts[1].trim());

    if (a == null || b == null) {
      setState(() => _result = 'Masukkan angka yang valid!');
      return;
    }

    if (b == 0 && _operation == 'pembagian') {
      setState(() => _result = 'Tidak dapat membagi dengan nol!');
      return;
    }

    final String simbol = _operations[_operation]!.simbol;
    final double hasil = switch (_operation) {
      'penjumlahan' => a + b,
      'pengurangan' => a - b,
      'perkalian' => a * b,
      'pembagian' => a / b,
      _ => 0,
    };

    setState(() {
      _result = ' ${_numFormat(hasil)}';
    });
  }

  String _numFormat(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  void _clear() {
    _displayController.clear();
    _result = '';
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _displayController,
                    onChanged: (value) {
                      setState(() {
                        _hitung();
                      });
                    },
                    showCursor: true,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _operation == 'deret'
                          ? 'Masukkan Deret (pisahkan dengan koma/spasi)'
                          : 'Masukkan angka',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _result,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                   
                ],
              ),
            ),
          ),

          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _gridButtons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 14,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final btn = _gridButtons[index];
                Color btnColor = Colors.white;
                Color textColor = Colors.black;

                if (btn == '=') {
                  btnColor = Colors.deepPurple;
                  textColor = Colors.white;
                } else if (btn == 'C' || btn == '⌫') {
                  btnColor = Colors.redAccent;
                  textColor = Colors.white;
                } else if (['+', '-', '×', '÷', 'G/G', 'Deret']
                    .contains(btn)) {
                  btnColor = Colors.deepPurple.shade100;
                  textColor = Colors.deepPurple.shade900;
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _onGridButtonPressed(btn),
                  child: Text(btn,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OperationInfo {
  const OperationInfo(this.nama, this.simbol, this.simbolTab);

  final String nama;
  final String simbol;
  final String simbolTab;
}
