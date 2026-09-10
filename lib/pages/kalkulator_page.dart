import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KalkulatorPage(),
  ));
}

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final TextEditingController _displayController = TextEditingController();

  late String _operation;
  String _result = '';

  final List<String> _gridButtons = [
    'C', '⌫', 'G/G', 'Sn',
    '7', '8', '9', '÷',
    '4', '5', '6', '×',
    '1', '2', '3', '-',
    '0', '.', ',', '+',
  ];

  @override
  void initState() {
    super.initState();
    _operation = "";
    _displayController.addListener(() {
      _hitung();
    });
  }

  void _onGridButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _clear();
        return;
      }
      
      if (value == '⌫') {
        if (_displayController.text.isNotEmpty) {
          if (_displayController.text.endsWith(' ')) {
            _displayController.text = _displayController.text
                .substring(0, _displayController.text.length - 3);
          } else {
            _displayController.text = _displayController.text
                .substring(0, _displayController.text.length - 1);
          }
        }
        return;
      }

      if (['+', '-', '×', '÷'].contains(value)) {
        _operation = 'kalkulator'; 
        String text = _displayController.text;

        if (text.endsWith(' + ') || text.endsWith(' - ') || text.endsWith(' × ') || text.endsWith(' ÷ ')) {
          _displayController.text = text.substring(0, text.length - 3) + ' $value ';
        } else if (text.isNotEmpty) {
          _displayController.text += ' $value ';
        } else if (value == '-') {
          _displayController.text += '-';
        }
        return;
      }

      if (value == 'G/G') {
        _operation = 'ganjil_genap';
        _hitung();
        return;
      }

      // Jika pindah mode ke Deret
      if (value == 'Sn') {
        _operation = 'deret';
        _hitung(); 
        return;
      }

      _displayController.text += value;
    });
  }

  void _hitung() {
    final String raw = _displayController.text.trim();
    if (raw.isEmpty) {
      setState(() => _result = '');
      return;
    }

    if (_operation == 'ganjil_genap') {
      final dynamic num = raw;
      if (num is String) {
        setState(() => _result = 'Nilai tidak valid!');{
          return;
        }
      }
      int.tryParse(raw);
      if (num == null) {
        setState(() => _result = 'Masukkan 1 angka bulat!');
        return;
      }
      setState(() {
        _result = '$num adalah Bilangan ${num % 2 == 0 ? "GENAP" : "GANJIL"}';
      });
      return;
    }

    if (_operation == 'deret') {
      final List<String> items = raw.split(RegExp(r',+'));
      double total = 0;
      int count = 0;
      for (var item in items) {
        double? val = double.tryParse(item.replaceAll(',', '.'));
        if (val != null) {
          total += val;
          count++;
        }
      }
      setState(() {
        _result = count > 0
            ? 'Total $count data deret = ${_numFormat(total)}'
            : 'Nilai tidak valid!';
      });
      return;
    }

    try {
      List<String> tokens = raw.split(' ').where((e) => e.isNotEmpty).toList();

      if (tokens.isEmpty) return;

      if (['+', '-', '×', '÷'].contains(tokens.last)) {
        tokens.removeLast();
      }

      if (tokens.isEmpty) return; 

      int i = 1;
      while (i < tokens.length - 1) {
        if (tokens[i] == '×' || tokens[i] == '÷') {
          double a = double.parse(tokens[i - 1].replaceAll(',', '.'));
          double b = double.parse(tokens[i + 1].replaceAll(',', '.'));

          if (tokens[i] == '÷' && b == 0) {
            setState(() => _result = 'Tidak dapat membagi dengan nol!');
            return;
          }

          double res = tokens[i] == '×' ? a * b : a / b;
          tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        } else {
          i += 2;
        }
      }

      i = 1;
      while (i < tokens.length - 1) {
        if (tokens[i] == '+' || tokens[i] == '-') {
          double a = double.parse(tokens[i - 1].replaceAll(',', '.'));
          double b = double.parse(tokens[i + 1].replaceAll(',', '.'));

          double res = tokens[i] == '+' ? a + b : a - b;
          tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        } else {
          i += 2;
        }
      }

      if (tokens.length == 1) {
        double hasil = double.parse(tokens[0]);
        setState(() {
          _result = ' ${_numFormat(hasil)}';
        });
      }
    } catch (e) {
    }
  }

  String _numFormat(double value) {
    double absVal = value.abs();

    // Jika mencapai 1 miliar atau lebih, gunakan format eksponensial (e)
    if (absVal >= 1000000000) {
      return value.toStringAsExponential(0);
    } 

    // Format normal untuk angka biasa (menghilangkan .0 jika bilangan bulat)
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
        title: const Text('Kalkulator'),
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
                    readOnly: true,
                    showCursor: true,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _operation == 'deret'
                          ? 'Mode Deret (pisahkan koma)'
                          : _operation == 'ganjil_genap'
                              ? 'Mode Ganjil / Genap'
                              : 'Mode Kalkulator',
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
                          fontSize: 22, fontWeight: FontWeight.bold),
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
                mainAxisSpacing: 16,
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
                } else if (['+', '-', '×', '÷', 'G/G', 'Sn'].contains(btn)) {
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
                          fontSize: 22, fontWeight: FontWeight.w500)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}