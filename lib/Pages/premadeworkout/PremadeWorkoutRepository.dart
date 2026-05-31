import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/PremadeSplitModel.dart';

class PremadeWorkoutRepository {
  final _supabase = Supabase.instance.client;

  Future<PremadeSplitModel> getSplit(String splitId) async {
    final data = await _supabase
        .from('premade_splits')
        .select('''
          id, name, description,
          premade_split_days!fk_split (
            id, name, day_order,
            premade_split_exercises (
              order_index,
              exercises (id, name)
            )
          )
        ''')
        .eq('id', splitId)
        .single();
    return PremadeSplitModel.fromJson(data);
  }

  Future<void> saveToUserSplits(PremadeSplitModel split, String userId) async {
    final newSplit = await _supabase
        .from('workout_splits')
        .insert({'name': split.name, 'user_id': userId})
        .select()
        .single();
    final newSplitId = newSplit['id'] as String;

    for (final day in split.days) {
      final newDay = await _supabase
          .from('split_days')
          .insert({
            'name': day.name,
            'day_order': day.dayOrder,
            'split_id': newSplitId,
          })
          .select()
          .single();
      final newDayId = newDay['id'] as String;

      for (final ex in day.exercises) {
        await _supabase.from('split_exercises').insert({
          'split_day_id': newDayId,
          'exercise_id': ex.id,
          'order_index': ex.orderIndex,
        });
      }
    }
  }
}
