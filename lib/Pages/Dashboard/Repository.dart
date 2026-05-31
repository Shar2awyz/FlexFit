import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/services.dart';
import 'model/workout_detail_model.dart';
import 'model/workout_history_model.dart';

class DashboardRepository {
  final supabase = Supabase.instance.client;
  final supa service = supa();

  Future<Map<String, dynamic>?> getDashboardData(String userId) async {
    final userData = await service.getuserdata(userId);
    if (userData == null) return null;

    // Prefer the stored image_url; fall back to Google/OAuth avatar metadata.
    String? imageUrl = userData['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      final meta = supabase.auth.currentUser?.userMetadata;
      imageUrl = meta?['avatar_url'] as String?;
    }

    return {
      ...userData,
      'image_url': imageUrl,
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

  Future<int> getTrackedProgress(String userId) async {
    final rows = await supabase
        .from('tracked_exercises')
        .select('exercise_id, goal_weight')
        .eq('user_id', userId);

    if ((rows as List).isEmpty) return 0;

    double total = 0;
    int count = 0;

    for (final row in rows) {
      final goalWeight = (row['goal_weight'] as num?)?.toDouble();
      if (goalWeight == null || goalWeight <= 0) continue;

      final exerciseId = row['exercise_id'] as String;

      final we = await supabase
          .from('workout_exercises')
          .select('id, workouts!inner(user_id)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', userId);

      if ((we as List).isEmpty) continue;
      final ids = we.map((e) => e['id'] as String).toList();

      final sets = await supabase
          .from('sets')
          .select('weight')
          .inFilter('workout_exercise_id', ids);

      if ((sets as List).isEmpty) continue;

      final maxWeight = (sets as List)
          .map((s) => (s['weight'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);

      total += (maxWeight / goalWeight).clamp(0.0, 1.0);
      count++;
    }

    if (count == 0) return 0;
    return ((total / count) * 100).round();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}