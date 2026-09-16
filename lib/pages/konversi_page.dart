import 'package:flutter/material.dart';
import 'hitungkonversi.dart';

class KonversiPage extends StatelessWidget {
  const KonversiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konversi Kalender'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Hijriah'),
              Tab(text: 'Umur'),
              Tab(text: 'Weton'),
              Tab(text: 'Saka Bali'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TanggalTab(
              judul: 'Pilih Tanggal Masehi',
              labelHasil: 'Tanggal Hijriah',
              konversi: CalendarUtils.formatHijriah,
            ),
            const _UmurTab(),
            _TanggalTab(
              judul: 'Pilih Tanggal',
              labelHasil: 'Weton',
              konversi: CalendarUtils.wetonDari,
            ),
            _TanggalTab(
              judul: 'Pilih Tanggal',
              labelHasil: '',
              konversi: CalendarUtils.formatSakaBali,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB TANGGAL ====================

class _TanggalTab extends StatefulWidget {
  final String judul;
  final String labelHasil;
  final String Function(DateTime) konversi;

  const _TanggalTab({
    required this.judul,
    required this.labelHasil,
    required this.konversi,
  });

  @override
  State<_TanggalTab> createState() => _TanggalTabState();
}

class _TanggalTabState extends State<_TanggalTab> {
  DateTime? tanggal;
  String? hasil;

  Future<void> pilihTanggal() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        tanggal = result;
        hasil = widget.konversi(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: pilihTanggal,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              tanggal == null
                  ? widget.judul
                  : '${tanggal!.day}/${tanggal!.month}/${tanggal!.year}',
            ),
          ),
          const SizedBox(height: 24),
          if (hasil != null)
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.labelHasil.isEmpty
                      ? hasil!
                      : '${widget.labelHasil}:\n$hasil',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== TAB UMUR ====================

class _UmurTab extends StatefulWidget {
  const _UmurTab();

  @override
  State<_UmurTab> createState() => _UmurTabState();
}

class _UmurTabState extends State<_UmurTab> {
  DateTime? lahir;
  Map<String, int>? umur;

  Future<void> pilihTanggal() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (result != null) {
      final tanggal = DateTime(result.year, result.month, result.day);

      setState(() {
        lahir = tanggal;
        umur = CalendarUtils.hitungUmur(tanggal, DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: pilihTanggal,
            icon: const Icon(Icons.cake),
            label: Text(
              lahir == null
                  ? 'Pilih Tanggal Lahir'
                  : '${lahir!.day}/${lahir!.month}/${lahir!.year}',
            ),
          ),
          const SizedBox(height: 24),
          if (umur != null)
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Umur kamu:\n'
                  '${umur!['tahun']} tahun, '
                  '${umur!['bulan']} bulan, '
                  '${umur!['hari']} hari\n'
                  '${umur!['jam']} jam, '
                  '${umur!['menit']} menit, '
                  '${umur!['detik']} detik',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
