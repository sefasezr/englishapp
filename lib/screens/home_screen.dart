import 'package:flutter/material.dart';
import 'package:kurs/screens/chat_screen.dart';
import 'package:kurs/screens/unit_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAEEFFF), // Arka plan
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: const Color(0xFF4252B4), // Üst bar
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // TODO: Kelime çalışma sayfasına yönlendir
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UnitSelectionScreen()),
            );
          },
          child: const Text(
            'Kelime Çalış',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
