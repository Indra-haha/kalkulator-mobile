import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../theme/quiz_option_theme.dart';
// Import file engine kalkulator kamu di sini (sesuaikan path foldernya)
import '../../engine/kalkulator_engine.dart';

class QuizTestPage extends StatefulWidget {
  final Quizes quiz;

  const QuizTestPage({super.key, required this.quiz});

  @override
  State<QuizTestPage> createState() => _QuizTestPageState();
}

class _QuizTestPageState extends State<QuizTestPage> {
  int _currentIndex = 0;
  int _totalScore = 0;

  Timer? _timer;
  int _timeLeft = 0;
  double _maxDuration = 12.0;

  // Stopwatch presisi milidetik
  final Stopwatch _stopwatch = Stopwatch();

  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool? _isUserCorrect;
  int _gainedScore = 0;

  @override
  void initState() {
    super.initState();
    _initQuestionSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _initQuestionSession() {
    if (widget.quiz.questions.isEmpty) return;

    final currentQuestion = widget.quiz.questions[_currentIndex];
    _maxDuration = currentQuestion.duration > 0
        ? currentQuestion.duration
        : 12.0;
    _timeLeft = _maxDuration.toInt();

    _stopwatch.reset();
    _stopwatch.start();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          double elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
          _timeLeft = (_maxDuration - elapsedSeconds).ceil();
          if (_timeLeft < 0) _timeLeft = 0;
        });
      } else {
        _handleAnswer(-1); // Waktu habis
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_isAnswered) return;
    _timer?.cancel();
    _stopwatch.stop();

    final currentQuestion = widget.quiz.questions[_currentIndex];

    const int correctIndex = 0; // Kunci jawaban testing lokal (Index 0)
    bool isBenar = (selectedIndex == correctIndex);
    int bobotMaks = currentQuestion.skor > 0 ? currentQuestion.skor : 50;
    int elapsedMs = _stopwatch.elapsedMilliseconds;

    // ====================================================================
    // MEMANGGIL CLASS KALKULASI & MENERIMA RESPON SKOR
    // ====================================================================
    int poinDiperoleh = KalkulatorEngine.hitungSkorWaktu(
      isBenar: isBenar,
      elapsedMs: elapsedMs,
      maxDurationSec: _maxDuration.toInt(),
      bobotMaks: bobotMaks,
    );

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _isAnswered = true;
      _isUserCorrect = isBenar;
      _gainedScore = poinDiperoleh;
    });

    if (poinDiperoleh > 0) {
      setState(() {
        _totalScore += poinDiperoleh;
      });
    }

    // Jeda 3 detik sebelum lanjut ke soal berikutnya
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _isUserCorrect = null;
        _gainedScore = 0;
      });
      _initQuestionSession();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kuis Selesai! 🎉'),
        content: Text('Total Poin Kamu: $_totalScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: Text('Tidak ada soal dalam kuis ini.')),
      );
    }

    final currentQuestion = widget.quiz.questions[_currentIndex];
    final totalQuestions = widget.quiz.questions.length;
    final int currentQuestionSkor = currentQuestion.skor > 0
        ? currentQuestion.skor
        : 50;

    return Scaffold(
      appBar: AppBar(title: const Text("Testing (Modular Engine)")),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Judul Kategori & Indeks Soal + Kotak Bobot & Total Skor Poin
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.quiz.title.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF4648D4),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.33,
                            letterSpacing: 0.60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE7EEFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF4648D4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Soal ${_currentIndex + 1} ',
                                      style: const TextStyle(
                                        color: Color(0xFF111C2D),
                                        fontSize: 14,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.43,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/ $totalQuestions',
                                      style: const TextStyle(
                                        color: Color(0xFF464554),
                                        fontSize: 14,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.43,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Samping _totalScore: Tampilkan Bobot Maksimal Soal & Kotak Skor Akumulasi
                    Row(
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Center(
                            child: Text(
                              'Max $currentQuestionSkor pts',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDDB8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$_totalScore',
                              style: const TextStyle(
                                color: Color(0xFF2A1700),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bagian Timer Hitung Mundur (Detik)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _timeLeft <= 3
                              ? Colors.red
                              : const Color(0xFF4648D4),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_timeLeft',
                            style: TextStyle(
                              color: _timeLeft <= 3
                                  ? Colors.red
                                  : const Color(0xFF111C2D),
                              fontSize: 28,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'DETIK',
                            style: TextStyle(
                              color: Color(0xFF464554),
                              fontSize: 10,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Kartu Pertanyaan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentQuestion.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF111C2D),
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      height: 1.38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daftar Pilihan Jawaban Vertikal + Feedback Warna
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(currentQuestion.options.length, (
                    index,
                  ) {
                    final themeIndex = index % optionThemes.length;
                    final theme = optionThemes[themeIndex];

                    Color currentBgColor = theme.bg;
                    const int correctIndex = 0; // Kunci jawaban benar

                    if (_isAnswered) {
                      if (index == correctIndex) {
                        currentBgColor = const Color(
                          0xFFC8E6C9,
                        ); // Hijau (Benar)
                      } else if (index == _selectedAnswerIndex) {
                        currentBgColor = const Color(
                          0xFFFFDAD6,
                        ); // Merah (Salah pilih)
                      } else {
                        currentBgColor = theme.bg.withValues(alpha: 0.4);
                      }
                    } else if (_selectedAnswerIndex == index) {
                      currentBgColor = Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.15),
                        theme.bg,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: _isAnswered ? null : () => _handleAnswer(index),
                        child: Container(
                          width: double.infinity,
                          height: 84,
                          decoration: ShapeDecoration(
                            color: currentBgColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 4, color: theme.border),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 16,
                                top: 16,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: theme.dot,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + themeIndex),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 80,
                                top: 20.50,
                                child: Container(
                                  width: 226,
                                  padding: const EdgeInsets.only(
                                    top: 9,
                                    left: 12,
                                    right: 12,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    currentQuestion.options[index],
                                    style: TextStyle(
                                      color: theme.border,
                                      fontSize: 16,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // BANNER NOTIFIKASI DI BAWAH PILIHAN JAWABAN
              if (_isAnswered && _isUserCorrect != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _isUserCorrect!
                        ? const Color(0xFFC8E6C9)
                        : const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isUserCorrect!
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF93000A),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isUserCorrect! ? Icons.check_circle : Icons.cancel,
                        color: _isUserCorrect!
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFF93000A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isUserCorrect!
                            ? 'Kamu Benar! (+$_gainedScore Poin)'
                            : 'Kamu Salah! (+0 Poin)',
                        style: TextStyle(
                          color: _isUserCorrect!
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF93000A),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
