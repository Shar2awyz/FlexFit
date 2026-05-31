import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/SplitSummaryModel.dart';

class StartWorkoutRepository {
  final _supabase = Supabase.instance.client;

  Future<List<SplitSummaryModel>> getUserSplits(String userId) async {
    final data = await _supabase
        .from('workout_splits')
        .select('id, name, split_days(id, name, day_order)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => SplitSummaryModel.fromJson(e)).toList();
  }

  Future<List<PremadeSplitSummary>> getPremadeSplits() async {
    final data = await _supabase
        .from('premade_splits')
        .select('id, name, photo_url');
    return (data as List).map((e) => PremadeSplitSummary.fromJson(e)).toList();
  }

  Future<void> deleteSplit(String splitId) async {
    await _supabase.from('workout_splits').delete().eq('id', splitId);
  }

  Future<void> renameSplit(String splitId, String name) async {
    await _supabase
        .from('workout_splits')
        .update({'name': name})
        .eq('id', splitId);
  }
}
