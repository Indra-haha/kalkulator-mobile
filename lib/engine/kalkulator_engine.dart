// ====================================================================
// KALKULATOR ENGINE: Modul terpisah untuk komputasi skor & ekspresi matematika
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

  static Expr angka(num nilai) => AngkaExpr(nilai.toDouble());
  static Expr tambah(Expr a, Expr b) => BinerExpr(a, '+', b);
  static Expr kurang(Expr a, Expr b) => BinerExpr(a, '-', b);
  static Expr kali(Expr a, Expr b) => BinerExpr(a, '×', b);
  static Expr bagi(Expr a, Expr b) => BinerExpr(a, '÷', b);
  static Expr negasi(Expr target) => NegExpr(target);

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

  // Method khusus untuk menghitung skor kuis berdasarkan ketepatan waktu milidetik
  static int hitungSkorWaktu({
    required bool isBenar,
    required int elapsedMs,
    required int maxDurationSec,
    required int bobotMaks,
  }) {
    // Jika jawaban salah, langsung kembalikan respon 0 poin
    if (!isBenar) return 0;

    double maxMs = maxDurationSec * 1000.0;
    double sisaMs = maxMs - elapsedMs;
    if (sisaMs < 0) sisaMs = 0;

    // Komposisi menggunakan pohon ekspresi engine: (Sisa Waktu Ms ÷ Total Durasi Ms) × Bobot Maksimal
    Expr exprSisaMs = angka(sisaMs);
    Expr exprMaxMs = angka(maxMs);
    Expr exprBobot = angka(bobotMaks.toDouble());

    Expr rasioExpr = bagi(exprSisaMs, exprMaxMs);
    Expr totalSkorExpr = kali(rasioExpr, exprBobot);

    // Evaluasi hasil perhitungan via engine
    double? hasilHitung = hitung(totalSkorExpr);
    if (hasilHitung == null) return 0;

    int finalScore = hasilHitung.round();

    // Minimal tetap mendapat 5 poin jika benar, atau 0 jika waktu habis total
    return finalScore < 5 && sisaMs > 0 ? 5 : finalScore;
  }

  static Expr? parse(String raw) {
    List<String> tokens = _tokenize(raw);
    if (tokens.isEmpty) return null;

    Expr? expr = _tryParse(tokens);
    if (expr == null && ['+', '-', '×', '÷'].contains(tokens.last)) {
      tokens = tokens.sublist(0, tokens.length - 1);
      expr = _tryParse(tokens);
    }
    return expr;
  }

  static List<String> _tokenize(String raw) {
    return RegExp(
      r'(\d+[\d,.]*|[+\-×÷])',
    ).allMatches(raw).map((m) => m.group(1)!).toList();
  }

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
      if (token == '+') return null;
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
