import '../PremadeWorkoutRepository.dart';
import '../model/PremadeSplitModel.dart';

class PremadeWorkoutViewModel {
  final PremadeWorkoutRepository _repo;

  PremadeWorkoutViewModel(this._repo);

  Future<PremadeSplitModel> loadSplit(String splitId) =>
      _repo.getSplit(splitId);

  Future<void> saveRoutine(PremadeSplitModel split, String userId) =>
      _repo.saveToUserSplits(split, userId);
}
