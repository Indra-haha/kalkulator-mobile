import 'package:flutter/material.dart';

import 'home_page.dart';
import 'kalkulator_page.dart';
import 'quiz_page.dart';
import 'konversi_page.dart';

class MainShell extends StatefulWidget {
  final Map<String, dynamic>? user;

  const MainShell({super.key, this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(user: widget.user),
      QuizPage(
        user: widget.user,
        userId: widget.user?['id'] == null
            ? null
            : int.tryParse('${widget.user?['id']}'),
      ),
      const KalkulatorPage(),
      const KonversiPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Kalkulator'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Konversi'),
        ],
      ),
    );
  }
}
