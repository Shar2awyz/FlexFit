import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/ExerciseListItem.dart';

class AddExerciseRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ExerciseListItem>> getAllExercises() async {
    final data = await _supabase.from('exercises').select();
    return (data as List).map((e) => ExerciseListItem.fromJson(e)).toList();
  }
}
