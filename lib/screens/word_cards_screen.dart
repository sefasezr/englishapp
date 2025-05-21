// lib/screens/word_cards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurs/screens/quiz_screen.dart';
import 'package:kurs/services/student_service.dart';
import '../model/word.dart';
import '../services/word_service.dart';

class WordCardsScreen extends ConsumerStatefulWidget {
  final int classLevel;
  final String unitName;
  const WordCardsScreen({
    required this.classLevel,
    required this.unitName,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<WordCardsScreen> createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends ConsumerState<WordCardsScreen> {
  late PageController _pageController;
  late Future<List<Word>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _wordsFuture = ref
        .read(wordServiceProvider)
        .getWordsForUnit(widget.classLevel, widget.unitName);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentService = ref.read(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classLevel}. Sınıf • ${widget.unitName}'),
      ),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final words = snap.data!;
          return PageView.builder(
            controller: _pageController,
            itemCount: words.length,
            itemBuilder: (ctx, i) {
              final w = words[i];
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(w.english, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 16),
                      Text(w.turkish, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await studentService.addUnknownWord(w.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Bu kelime bilmediklerime eklendi.'),
                              ),
                            );
                            if (i < words.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hata: $e')),
                            );
                          }
                        },
                        child: const Text('Bilmiyorum'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Quiz Başlat',
        child: const Icon(Icons.quiz),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                classLevel: widget.classLevel,
                unitName: widget.unitName,
              ),
            ),
          );
        },
      ),
    );
  }
}
