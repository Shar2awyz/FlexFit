import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/services.dart';
import 'model/workout_detail_model.dart';
import 'model/workout_history_model.dart';

class DashboardRepository {
  final supabase = Supabase.instance.client;
  final supa service = supa();

  Future<Map<String, dynamic>?> getDashboardData(String userId) async {
    final userData = await service.getuserdata(userId);

    final imageData = await supabase
        .from('Users')
        .select('image_url')
        .eq('id', userId)
        .single();

    if (userData == null) return null;

    return {
      ...userData,
      "image_url": imageData['image_url'],
    };
  }

  Future<List<WorkoutHistoryModel>> getWorkoutHistory(String userId) async {
    final data = await supabase
        .from('workouts')
        .select('id, name, date, duration_seconds, workout_exercises(id, sets(id))')
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(20);

    return (data as List)
        .map((e) => WorkoutHistoryModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkoutSessionDetail> getWorkoutDetail(String workoutId) async {
    final data = await supabase
        .from('workouts')
        .select(
          'id, name, date, duration_seconds, workout_exercises(id, exercises(id, name, muscle_group), sets(id, set_number, reps, weight))',
        )
        .eq('id', workoutId)
        .single();

    return WorkoutSessionDetail.fromMap(data);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}