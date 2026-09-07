import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tugas_1_kalkulator/main.dart';

void main() {
  testWidgets('Login page menampilkan field username dan password',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorApp());

    expect(find.text('Login Aplikasi Kalkulator'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Login gagal dengan password salah', (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorApp());

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'salah');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Username atau password salah!'), findsOneWidget);
  });

  testWidgets('Login berhasil menampilkan menu utama', (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorApp());

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Menu Utama'), findsOneWidget);
    expect(find.text('Data Kelompok'), findsOneWidget);
    expect(find.text('Bilangan Ganjil / Genap'), findsOneWidget);
    expect(find.text('Jumlah Total Angka'), findsOneWidget);
  });
}