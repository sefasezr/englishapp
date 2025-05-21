// lib/screens/unit_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/unit_status.dart';
import '../services/word_service.dart';
import '../repository/unit_status_repository.dart';
import 'word_cards_screen.dart';

/// 1) Sınıf–ünite eşlemesini getirir
final classUnitsProvider = FutureProvider<Map<int, List<String>>>((ref) {
  return ref.read(wordServiceProvider).getClassUnitsMap();
});

/// 2) Kullanıcının tüm unit_status dokümanlarını dinler
final unitStatusStreamProvider = StreamProvider<List<UnitStatus>>((ref) {
  return ref.read(unitStatusRepositoryProvider).watchAllStatuses();
});

class UnitSelectionScreen extends ConsumerWidget {
  const UnitSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(classUnitsProvider);
    final statusAsync = ref.watch(unitStatusStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ünite Seçimi')),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Üniteler yüklenirken bir hata oluştu:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (classUnits) => statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Ünite durumları yüklenirken bir hata oluştu:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (statuses) {
            // id → UnitStatus
            final statusMap = {for (var s in statuses) s.id: s};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: classUnits.entries.map((entry) {
                final lvl = entry.key;
                final units = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$lvl. Sınıf',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: units.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final unitName = units[i];
                          final docId = '${lvl}_$unitName';
                          final status = statusMap[docId];
                          // İlk ünite her zaman açık, diğerleri status?.isUnlocked
                          final unlocked =
                              i == 0 || (status?.isUnlocked ?? false);

                          return Opacity(
                            opacity: unlocked ? 1 : 0.5,
                            child: GestureDetector(
                              onTap: unlocked
                                  ? () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) => WordCardsScreen(
                                            classLevel: lvl,
                                            unitName: unitName,
                                          ),
                                        ),
                                      )
                                  : null,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  color: Color(0xFF7A4DFF),
                                  width: 100,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        unitName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: unlocked
                                              ? Color(0xFFFFB627)
                                              : Colors.grey,
                                        ),
                                      ),
                                      if (!unlocked)
                                        const Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
