import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutSplitRepository {
  final _supabase = Supabase.instance.client;

  Future<String> createSplit(String userId, String name) async {
    final res = await _supabase
        .from('workout_splits')
        .insert({'user_id': userId, 'name': name})
        .select('id')
        .single();
    return res['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getDays(String splitId) async {
    final data = await _supabase
        .from('split_days')
        .select('id, name, day_order')
        .eq('split_id', splitId)
        .order('day_order');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> deleteDay(String dayId) async {
    await _supabase.from('split_exercises').delete().eq('split_day_id', dayId);
    await _supabase.from('split_days').delete().eq('id', dayId);
  }
}
