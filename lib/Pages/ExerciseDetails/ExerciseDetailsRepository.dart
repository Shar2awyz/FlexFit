import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/ExerciseDetailModel.dart';

class ExerciseDetailsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ExerciseDetailModel>> getByMuscle(String muscle) async {
    final data = await _supabase
        .from('exercises')
        .select()
        .eq('muscle_group', muscle);
    return (data as List).map((e) => ExerciseDetailModel.fromJson(e)).toList();
  }
}
