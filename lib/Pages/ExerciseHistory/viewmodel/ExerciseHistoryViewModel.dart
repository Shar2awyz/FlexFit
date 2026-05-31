import '../ExerciseHistoryRepository.dart';
import '../model/ExerciseSetRecord.dart';

class ExerciseHistoryViewModel {
  final ExerciseHistoryRepository _repo;

  ExerciseHistoryViewModel(this._repo);

  Future<List<ExerciseSetRecord>> loadHistory(
    String exerciseId,
    String userId,
  ) =>
      _repo.getSets(exerciseId, userId);
}
