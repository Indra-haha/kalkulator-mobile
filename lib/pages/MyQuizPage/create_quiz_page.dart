import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quiz.dart';
import '../../services/api_client.dart';
import '../../services/quiz_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';

const _fieldBg = Color(0xFFF0F3FF);
const _placeholder = Color(0xFF6B7280);
const _questionCardBg = Color(0xFFE7EEFF);
const _danger = Color(0xFFBA1A1A);

class _AnswerStyle {
  final Color background;
  final Color border;
  final Color dot;
  final String hint;

  const _AnswerStyle({
    required this.background,
    required this.border,
    required this.dot,
    required this.hint,
  });
}

const _answerStyles = [
  _AnswerStyle(
    background: Color(0xFFFFDAD6),
    border: Color(0xFF93000A),
    dot: Color(0xFFBA1A1A),
    hint: 'Jawaban merah...',
  ),
  _AnswerStyle(
    background: Color(0xFFDBE1FF),
    border: Color(0xFF001453),
    dot: Color(0xFF4648D4),
    hint: 'Jawaban biru...',
  ),
  _AnswerStyle(
    background: Color(0xFFFFF9C4),
    border: Color(0xFF825100),
    dot: Color(0xFFA36700),
    hint: 'Jawaban kuning...',
  ),
  _AnswerStyle(
    background: Color(0xFFC8E6C9),
    border: Color(0xFF1B5E20),
    dot: Color(0xFF2E7D32),
    hint: 'Jawaban hijau...',
  ),
];

const _durations = [1.5, 2.0, 3.0, 5.0];

class _QuestionData {
  final TextEditingController question = TextEditingController();
  final List<TextEditingController> options =
      List.generate(4, (_) => TextEditingController());
  final TextEditingController skor = TextEditingController();
  int? correctIdx;
  double duration = 2;

  void dispose() {
    question.dispose();
    for (final option in options) {
      option.dispose();
    }
    skor.dispose();
  }
}

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_QuestionData> _questions = [_QuestionData()];
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuestionData()));
  }

  void _removeQuestion(int index) {
    if (_questions.length == 1) return;
    setState(() => _questions.removeAt(index).dispose());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validate() {
    if (_titleController.text.trim().isEmpty) {
      return 'Judul quiz wajib diisi.';
    }
    if (_descriptionController.text.trim().isEmpty) {
      return 'Deskripsi quiz wajib diisi.';
    }
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.question.text.trim().isEmpty) {
        return 'Pertanyaan ${i + 1} wajib diisi.';
      }
      for (var j = 0; j < question.options.length; j++) {
        if (question.options[j].text.trim().isEmpty) {
          return 'Jawaban ${j + 1} pada pertanyaan ${i + 1} wajib diisi.';
        }
      }
      if (question.correctIdx == null) {
        return 'Pilih jawaban benar untuk pertanyaan ${i + 1}.';
      }
      final skor = int.tryParse(question.skor.text.trim());
      if (skor == null || skor < 1 || skor > 50) {
        return 'Poin pertanyaan ${i + 1} harus berupa angka 1-50.';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _saving = true);

    final token = await SessionService.instance.getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Sesi login berakhir. Silakan login kembali.');
      return;
    }

    final questions = _questions
        .map(
          (question) => QuizQuestionInput(
            question: question.question.text.trim(),
            options: question.options.map((o) => o.text.trim()).toList(),
            correctIdx: question.correctIdx!,
            duration: question.duration,
            skor: int.parse(question.skor.text.trim()),
          ),
        )
        .toList();

    try {
      await QuizService.instance.createQuiz(
        token: token,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: questions,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Tidak dapat terhubung ke server. ($e)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  _buildLabel('Judul Quiz'),
                  const SizedBox(height: 8),
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildLabel('Deskripsi'),
                  const SizedBox(height: 8),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  for (var i = 0; i < _questions.length; i++) ...[
                    _buildQuestionCard(i),
                    const SizedBox(height: 20),
                  ],
                  _buildAddQuestionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'QUIZRUSH',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.2,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Simpan Quiz',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required double radius,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle ??
          GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _placeholder,
          ),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      decoration: _fieldDecoration(
        hint: 'Masukkan judul yang menarik...',
        radius: 32,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: null,
      minLines: 2,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      decoration: _fieldDecoration(
        hint: 'Masukkan deskripsi yang menarik...',
        radius: 19,
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _questionCardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.highlight,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Pertanyaan ${index + 1}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onHighlight,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _questions.length == 1
                    ? null
                    : () => _removeQuestion(index),
                child: Text(
                  'Hapus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: question.question,
            maxLines: null,
            minLines: 3,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: _fieldDecoration(
              hint: 'Tuliskan pertanyaan Anda di sini...',
              radius: 19,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF767586),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _answerStyles.length; i++) ...[
            _buildAnswerField(question, i),
            if (i < _answerStyles.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          _buildDurationAndSkor(question),
        ],
      ),
    );
  }

  Widget _buildAnswerField(_QuestionData question, int index) {
    final style = _answerStyles[index];
    final selected = question.correctIdx == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: style.border, width: 4),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: style.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: question.options[index],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                hintText: style.hint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => question.correctIdx = index),
            child: Container(
              width: 44,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? style.dot : style.dot.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationAndSkor(_QuestionData question) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Durasi'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: question.duration,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(19),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    items: [
                      for (final duration in _durations)
                        DropdownMenuItem(
                          value: duration,
                          child: Text(_durationLabel(duration)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => question.duration = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Poin (1-50)'),
              const SizedBox(height: 6),
              TextField(
                controller: question.skor,
                keyboardType: TextInputType.number,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                decoration: _fieldDecoration(
                  hint: '20',
                  radius: 19,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _placeholder,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddQuestionButton() {
    return OutlinedButton(
      onPressed: _addQuestion,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.cardBg,
        side: const BorderSide(color: AppColors.border, width: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.highlight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Tambah Pertanyaan',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(double duration) {
    final value =
        duration == duration.roundToDouble() ? duration.toInt() : duration;
    return '$value detik';
  }
}
