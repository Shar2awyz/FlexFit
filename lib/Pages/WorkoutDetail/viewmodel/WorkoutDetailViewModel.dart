import 'package:untitled6/Pages/Dashboard/Repository.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_detail_model.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_history_model.dart';

class WorkoutDetailViewModel {
  final DashboardRepository _repo;

  WorkoutDetailViewModel(this._repo);

  Future<WorkoutSessionDetail> loadDetail(WorkoutHistoryModel workout) =>
      _repo.getWorkoutDetail(workout.id);
}
