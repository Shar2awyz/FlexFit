import '../ExerciseDetailsRepository.dart';
import '../model/ExerciseDetailModel.dart';

class ExerciseDetailsViewModel {
  final ExerciseDetailsRepository _repo;

  ExerciseDetailsViewModel(this._repo);

  Future<List<ExerciseDetailModel>> loadExercises(String muscle) =>
      _repo.getByMuscle(muscle);
}
