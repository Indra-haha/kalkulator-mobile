import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_header_bar.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KalkulatorPage(),
    ),
  );
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
            _displayController.text = _displayController.text.substring(
              0,
              _displayController.text.length - 3,
            );
          } else {
            _displayController.text = _displayController.text.substring(
              0,
              _displayController.text.length - 1,
            );
          }
        }
        return;
      }

      if (['+', '-', '×', '÷'].contains(value)) {
        final String text = _displayController.text;
        _operation = text.contains(',') ? 'deret' : '';

        if (text.isEmpty) {
          // Di awal ekspresi, '-' langsung jadi tanda negatif; '+' tidak bisa.
          if (value == '-') {
            _displayController.text = '-';
          }
          return;
        }

        // Mode deret: minus boleh menempel langsung di belakang koma -> "5,-"
        if ((text.endsWith(',') || text.endsWith(', ')) && value == '-') {
          _displayController.text = text.endsWith(' ')
              ? '${text.substring(0, text.length - 1)}-'
              : '$text-';
          return;
        }

        final String core = text.trimRight();
        final bool prevOperator = core.isNotEmpty &&
            ['+', '-', '×', '÷'].contains(core[core.length - 1]);

        if (value == '-') {
          // '-' bisa jadi TANDA bilangan berikutnya (sesudah operator apa pun),
          // sesuai logika matematika. '+' tidak pernah jadi unary.
          _displayController.text = prevOperator ? '$core -' : '$core - ';
          return;
        }

        if (prevOperator) {
          _displayController.text =
              '${core.substring(0, core.length - 1).trimRight()} $value ';
          return;
        }

        _displayController.text += ' $value ';
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
      final bool validAngka = RegExp(r'^-?\d+$').hasMatch(raw);

      if (!validAngka) {
        setState(() => _result = 'Masukkan angka valid!');
        return;
      }

      final int? angka = int.tryParse(raw);
      if (angka == null) {
        setState(() => _result = 'Masukkan 1 angka bulat!');
        return;
      }

      setState(() {
        _result = '$angka adalah Bilangan ${angka % 2 == 0 ? "GENAP" : "GANJIL"}';
      });
      return;
    }

    if (_operation == 'deret') {
      final List<String> items = raw.split(RegExp(r',+'));
      double total = 0;
      int count = 0;
      for (var item in items) {
        double? val = double.tryParse(item.trim().replaceAll(',', '.'));
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

    // Mode Kalkulator: evaluasi multi-operator + precedence + unary minus
    // ditangani oleh KalkulatorEngine (OOP).
    final Expr? parsed = KalkulatorEngine.parse(raw);
    if (parsed == null) {
      setState(() => _result = '');
      return;
    }

    final double? hasil = KalkulatorEngine.hitung(parsed);
    if (hasil == null) {
      setState(() => _result = 'Tidak dapat membagi dengan nol!');
      return;
    }

    setState(() {
      _result = ' ${_numFormat(hasil)}';
    });
  }

  String _numFormat(double value) {
    // double absVal = value.abs();

    // Jika mencapai 1 miliar atau lebih, gunakan format eksponensial (e)
    // if (absVal >= 1000000000) {
    //   return value.toStringAsExponential(0);
    // }

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
      appBar: const AppHeaderBar(title: 'Kalkulator'),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final btn = _gridButtons[index];
                Color btnColor = Colors.white;
                Color textColor = Colors.black;

                if (btn == '=') {
                  btnColor = AppColors.primary;
                  textColor = Colors.white;
                } else if (btn == 'C' || btn == '⌫') {
                  btnColor = Colors.redAccent;
                  textColor = Colors.white;
                } else if (['+', '-', '×', '÷', 'G/G', 'Sn'].contains(btn)) {
                  btnColor = AppColors.softBg;
                  textColor = AppColors.ink;
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _onGridButtonPressed(btn),
                  child: Text(
                    btn,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Engine kalkulator OOP.
// Ekspresi dibangun sebagai pohon objek (Expr) sehingga bisa dikomposisi
// bebas/bersarang dan dipakai ulang oleh class lain:
//   KalkulatorEngine.tambah(KalkulatorEngine.tambah(a, b), c) == a + b + c
//   KalkulatorEngine.parse('2 + 3 × 4')
//     -> BinerExpr(2, '+', BinerExpr(3, '×', 4))   // hasil 14
// Precedence: × ÷ dikerjakan lebih dulu, lalu + -, urutan kiri-dulu.
// Unary minus: '-' menjadi tanda bilangan berikutnya (awal ekspresi atau
// sesudah operator apa pun); '+' tidak pernah menjadi unary.
// ====================================================================
sealed class Expr {
  const Expr();
}

class AngkaExpr extends Expr {
  const AngkaExpr(this.nilai);

  final double nilai;
}

class NegExpr extends Expr {
  const NegExpr(this.target);

  final Expr target;
}

class BinerExpr extends Expr {
  const BinerExpr(this.kiri, this.opr, this.kanan);

  final Expr kiri;
  final String opr;
  final Expr kanan;
}

class KalkulatorEngine {
  KalkulatorEngine._();

  // --- Builder: komposisi operasi (bersarang, tanpa batas kedalaman) ---
  static Expr angka(num nilai) => AngkaExpr(nilai.toDouble());

  static Expr tambah(Expr a, Expr b) => BinerExpr(a, '+', b);

  static Expr kurang(Expr a, Expr b) => BinerExpr(a, '-', b);

  static Expr kali(Expr a, Expr b) => BinerExpr(a, '×', b);

  static Expr bagi(Expr a, Expr b) => BinerExpr(a, '÷', b);

  static Expr negasi(Expr target) => NegExpr(target);

  // --- Evaluasi rekursif. Bagi nol (atau error lain) => null. ---
  static double? hitung(Expr expr) {
    switch (expr) {
      case AngkaExpr(:final nilai):
        return nilai;
      case NegExpr(:final target):
        final nilai = hitung(target);
        return nilai == null ? null : -nilai;
      case BinerExpr(:final kiri, :final opr, :final kanan):
        final a = hitung(kiri);
        final b = hitung(kanan);
        if (a == null || b == null) return null;
        switch (opr) {
          case '+':
            return a + b;
          case '-':
            return a - b;
          case '×':
            return a * b;
          case '÷':
            if (b == 0) return null;
            return a / b;
        }
        return null;
    }
  }

  // --- Parse dari string (dipakai KalkulatorPage untuk preview live). ---
  static Expr? parse(String raw) {
    List<String> tokens = _tokenize(raw);
    if (tokens.isEmpty) return null;

    Expr? expr = _tryParse(tokens);
    if (expr == null && ['+', '-', '×', '÷'].contains(tokens.last)) {
      // Input menggantung pada operator (mis. "5 +") -> potong lalu coba lagi.
      tokens = tokens.sublist(0, tokens.length - 1);
      expr = _tryParse(tokens);
    }
    return expr;
  }

  static List<String> _tokenize(String raw) {
    return RegExp(r'(\d+[\d,.]*|[+\-×÷])')
        .allMatches(raw)
        .map((m) => m.group(1)!)
        .toList();
  }

  // Recursive descent: parseTambahKurang -> parseKaliBagi -> parseUnary.
  static Expr? _tryParse(List<String> tokens) {
    int pos = 0;

    Expr? parseAngka() {
      if (pos >= tokens.length) return null;
      final double? nilai = double.tryParse(tokens[pos].replaceAll(',', '.'));
      if (nilai == null) return null;
      pos++;
      return AngkaExpr(nilai);
    }

    Expr? parseUnary() {
      if (pos >= tokens.length) return null;
      final String token = tokens[pos];
      if (token == '-') {
        pos++;
        final Expr? operand = parseUnary();
        return operand == null ? null : NegExpr(operand);
      }
      if (token == '+') return null; // unary plus tidak diizinkan
      return parseAngka();
    }

    Expr? parseKaliBagi() {
      final Expr? first = parseUnary();
      if (first == null) return null;
      Expr left = first;
      while (pos < tokens.length &&
          (tokens[pos] == '×' || tokens[pos] == '÷')) {
        final String opr = tokens[pos++];
        final Expr? right = parseUnary();
        if (right == null) return null;
        left = BinerExpr(left, opr, right);
      }
      return left;
    }

    Expr? parseTambahKurang() {
      final Expr? first = parseKaliBagi();
      if (first == null) return null;
      Expr left = first;
      while (pos < tokens.length &&
          (tokens[pos] == '+' || tokens[pos] == '-')) {
        final String opr = tokens[pos++];
        final Expr? right = parseKaliBagi();
        if (right == null) return null;
        left = BinerExpr(left, opr, right);
      }
      return left;
    }

    final Expr? expr = parseTambahKurang();
    if (expr == null || pos != tokens.length) return null;
    return expr;
  }
}
