// lib/services/unit_status_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/unit_status.dart';
import '../model/quiz_result.dart';
import '../repository/unit_status_repository.dart';

/// Provider
final unitStatusServiceProvider = Provider<UnitStatusService>((ref) {
  final repo = ref.watch(unitStatusRepositoryProvider);
  return UnitStatusService(repo);
});

class UnitStatusService {
  final UnitStatusRepository _repo;

  UnitStatusService(this._repo);

  /// Tüm ünitelerin durumlarını dinamik olarak dinle
  Stream<List<UnitStatus>> watchAll() => _repo.watchAllStatuses();

  /// Belirli bir ünitenin durumunu tek seferlik getir
  Future<UnitStatus> getStatus(int classLevel, String unit) =>
      _repo.fetchStatus(classLevel, unit);

  /// Uygulama ilk açıldığında JSON’dan okunan UnitStatus listesini kaydet
  Future<void> initialize(List<UnitStatus> statuses) =>
      _repo.initializeStatuses(statuses);

  /// Quiz geçildiğinde:
  ///  • Mevcut ünitenin completed=true, completedAt ve lastQuiz ile update
  ///  • Bir sonraki ünitenin isUnlocked=true yap
  Future<void> completeUnit({
    required UnitStatus current,
    required QuizResult result,
    UnitStatus? next,
  }) async {
    // 1) Mevcut üniteyi tamamlandı olarak işaretle
    await _repo.updateStatus(
      classLevel: current.classLevel,
      unit: current.unit,
      isCompleted: true,
      completedAt: DateTime.now(),
      lastQuiz: result.toJson(),
    );

    // 2) Varsa bir sonraki ünitenin kilidini aç
    if (next != null && !next.isUnlocked) {
      await _repo.updateStatus(
        classLevel: next.classLevel,
        unit: next.unit,
        isUnlocked: true,
      );
    }
  }
}
