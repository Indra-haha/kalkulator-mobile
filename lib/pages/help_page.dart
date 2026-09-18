import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bantuan"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.help_center,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            const Text(
              "Panduan Penggunaan Aplikasi",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Berikut adalah panduan singkat penggunaan setiap fitur yang tersedia pada aplikasi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            _buildHelpCard(
              icon: Icons.login,
              title: "Login / Registrasi",
              description:
                  "Masuk atau buat akun menggunakan NIM dan password.",
            ),

            _buildHelpCard(
              icon: Icons.home,
              title: "Home",
              description:
                  "Melihat menu utama dan quiz yang tersedia pada aplikasi.",
            ),

            _buildHelpCard(
              icon: Icons.quiz,
              title: "Quiz",
              description:
                  "Cari dan ikuti quiz menggunakan judul quiz atau kode room yang diberikan.",
            ),

            _buildHelpCard(
              icon: Icons.add_box,
              title: "Buat Quiz",
              description:
                  "Buat quiz sendiri dengan menambahkan pertanyaan, pilihan jawaban, dan informasi quiz.",
            ),

            _buildHelpCard(
              icon: Icons.calculate,
              title: "Kalkulator",
              description:
                  "Gunakan fitur kalkulator untuk melakukan perhitungan matematika serta pengecekan bilangan ganjil dan genap.",
            ),

            _buildHelpCard(
              icon: Icons.calendar_month,
              title: "Konversi",
              description:
                  "Pilih tanggal untuk melihat hasil konversi Hijriah, perhitungan umur, weton Jawa, dan tahun Saka Bali.",
            ),

            _buildHelpCard(
              icon: Icons.logout,
              title: "Logout",
              description:
                  "Keluar dari akun yang sedang digunakan dan kembali ke halaman login.",
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "Jika mengalami kendala saat menggunakan aplikasi, silakan hubungi administrator atau pengembang aplikasi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
      ),
    );
  }
}