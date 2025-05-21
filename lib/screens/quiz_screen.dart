// lib/screens/quiz_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurs/screens/unit_selection_screen.dart';
import '../model/word.dart';
import '../model/quiz_result.dart';
import '../model/unit_status.dart';
import '../services/word_service.dart';
import '../services/unit_status_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int classLevel;
  final String unitName;

  const QuizScreen({
    required this.classLevel,
    required this.unitName,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Future<List<Word>> _wordsFuture;
  List<Word>? _words;
  List<List<String>>? _options; // çoktan seçmeli seçenekler
  int _currentIndex = 0;
  int _correct = 0;
  bool _completed = false;

  static const double _passThreshold = 0.7; // %70 geçme koşulu
  static const int _maxQuestions = 15; // en fazla 15 soru

  @override
  void initState() {
    super.initState();
    _wordsFuture = ref
        .read(wordServiceProvider)
        .getWordsForUnit(widget.classLevel, widget.unitName)
        .then((list) {
      list.shuffle();
      final count = min(list.length, _maxQuestions);
      return list.sublist(0, count);
    });
  }

  List<List<String>> _generateOptions(List<Word> words) {
    final rnd = Random();
    return words.map((w) {
      // tüm diğer kelimelerin türkçelerini al
      final others = words
          .where((e) => e.id != w.id)
          .map((e) => e.turkish)
          .toList()
        ..shuffle();
      final wrongCount = min(3, others.length);
      final wrong = others.take(wrongCount).toList();
      final opts = [w.turkish, ...wrong]..shuffle(rnd);
      return opts;
    }).toList();
  }

  void _selectAnswer(String choice) {
    final correctAnswer = _words![_currentIndex].turkish;
    if (choice == correctAnswer) _correct++;
    if (_currentIndex < _words!.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _completed = true);
    }
  }

  Future<void> _finishQuiz() async {
    final takenAt = DateTime.now();
    final unitService = ref.read(unitStatusServiceProvider);

    // 1) Mevcut ünitenin durumu
    final currentStatus = await unitService.getStatus(
      widget.classLevel,
      widget.unitName,
    );

    // 2) Geçme kontrolü
    final passed = _correct >= ((_words!.length * _passThreshold).ceil());

    // 3) Sonraki ünitenin durumu (varsa)
    UnitStatus? nextStatus;
    if (passed) {
      final classUnitsMap =
          await ref.read(wordServiceProvider).getClassUnitsMap();
      final units = classUnitsMap[widget.classLevel]!;
      final idx = units.indexOf(widget.unitName);
      if (idx < units.length - 1) {
        nextStatus = await unitService.getStatus(
          widget.classLevel,
          units[idx + 1],
        );
      }
    }

    // 4) Güncelleme
    await unitService.completeUnit(
      current: currentStatus,
      result: QuizResult(
        score: _correct,
        total: _words!.length,
        passed: passed,
        takenAt: takenAt,
      ),
      next: nextStatus,
    );

    // 5) Sonuç dialog ve geri dönüş
    final msg = passed
        ? 'Tebrikler! Geçtiniz. 🔓 Sonraki ünite açıldı.'
        : 'Maalesef geçemediniz. Bir dahaki sefere!';
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Tamamlandı'),
        content: Text('$msg\nSonuç: $_correct / ${_words!.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => UnitSelectionScreen())),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classLevel}. Sınıf • ${widget.unitName} Test'),
      ),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // ilk defa yüklendiğinde seçenekleri oluştur
          if (_words == null) {
            _words = snap.data!;
            _options = _generateOptions(_words!);
          }

          if (_completed) {
            return Center(
              child: ElevatedButton(
                onPressed: _finishQuiz,
                child: const Text('Testi Bitir'),
              ),
            );
          }

          final w = _words![_currentIndex];
          final opts = _options![_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Soru ${_currentIndex + 1} / ${_words!.length}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  '"${w.english}" kelimesinin Türkçesi nedir?',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 24),
                // Çoktan seçmeli seçenekler
                ...opts.map((choice) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () => _selectAnswer(choice),
                        child:
                            Text(choice, style: const TextStyle(fontSize: 18)),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
