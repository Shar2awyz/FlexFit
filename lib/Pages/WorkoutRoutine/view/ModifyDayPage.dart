import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_fit/theme/app_colors.dart';


import '../../AddExercise/view/AddExercisePage.dart';
import '../../Components/app_route.dart';

class ModifyDayPage extends StatefulWidget {
  final String splitDayId;
  final String dayName;

  const ModifyDayPage({
    super.key,
    required this.splitDayId,
    required this.dayName,
  });

  @override
  State<ModifyDayPage> createState() => _ModifyDayPageState();
}

class _ModifyDayPageState extends State<ModifyDayPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _exercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _supabase
        .from('split_exercises')
        .select(
            'id, exercise_id, order_index, sets_count, exercises(name, muscle_group, photo_url)')
        .eq('split_day_id', widget.splitDayId)
        .order('order_index');

    setState(() {
      _exercises = (data as List).map((e) {
        final ex = e['exercises'] as Map<String, dynamic>;
        return {
          'split_exercise_id': e['id'] as String,
          'exercise_id': e['exercise_id'] as String,
          'order_index': e['order_index'] as int,
          'sets_count': (e['sets_count'] as int?) ?? 3,
          'name': ex['name'] as String? ?? '',
          'muscle_group': ex['muscle_group'] as String? ?? '',
          'photo_url': ex['photo_url'] as String?,
        };
      }).toList();
      _loading = false;
    });
  }

  Future<void> _persistOrder() async {
    for (int i = 0; i < _exercises.length; i++) {
      await _supabase
          .from('split_exercises')
          .update({'order_index': i + 1}).eq(
              'id', _exercises[i]['split_exercise_id'] as String);
    }
  }

  Future<void> _updateSetsCount(String id, int count) async {
    await _supabase
        .from('split_exercises')
        .update({'sets_count': count}).eq('id', id);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
    _persistOrder();
  }

  Future<void> _removeExercise(int index) async {
    final id = _exercises[index]['split_exercise_id'] as String;
    setState(() => _exercises.removeAt(index));
    await _supabase.from('split_exercises').delete().eq('id', id);
    await _persistOrder();
  }

  Future<void> _addExercises() async {
    final picked = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      appRoute((_) => const AddExercise(pickMode: true)),
    );
    if (picked == null || picked.isEmpty || !mounted) return;

    int nextOrder = _exercises.length + 1;
    for (final ex in picked) {
      await _supabase.from('split_exercises').insert({
        'split_day_id': widget.splitDayId,
        'exercise_id': ex['id'] as String,
        'order_index': nextOrder++,
        'sets_count': 3,
      });
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dayName,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: sw * 0.045,
              ),
            ),
            Text(
              'Drag to reorder · swipe to delete',
              style: TextStyle(
                  color: context.textMuted, fontSize: sw * 0.028),
            ),
          ],
        ),
        toolbarHeight: sw * 0.18,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: context.accentLight))
          : Column(
              children: [
                Expanded(
                  child: _exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fitness_center_rounded,
                                  color: context.textMuted, size: sw * 0.14),
                              SizedBox(height: sw * 0.04),
                              Text(
                                'No exercises yet',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: sw * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: sw * 0.01),
                              Text(
                                'Tap "Add Exercise" below',
                                style: TextStyle(
                                    color: context.textMuted,
                                    fontSize: sw * 0.032),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView(
                          padding: EdgeInsets.fromLTRB(
                              sw * 0.04, sw * 0.02, sw * 0.04, 0),
                          onReorder: _onReorder,
                          children: [
                            for (int i = 0; i < _exercises.length; i++)
                              _ExerciseTile(
                                key: ValueKey(
                                    _exercises[i]['split_exercise_id']),
                                exercise: _exercises[i],
                                index: i + 1,
                                sw: sw,
                                onDelete: () => _removeExercise(i),
                                onSetsChanged: (count) {
                                  setState(() =>
                                      _exercises[i]['sets_count'] = count);
                                  _updateSetsCount(
                                      _exercises[i]['split_exercise_id']
                                          as String,
                                      count);
                                },
                              ),
                          ],
                        ),
                ),

                // ── Add button ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: SizedBox(
                    width: double.infinity,
                    height: sw * 0.13,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.accent, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(sw * 0.035)),
                      ),
                      icon: Icon(Icons.add_rounded,
                          color: context.accentLight, size: sw * 0.055),
                      label: Text(
                        'Add Exercise',
                        style: TextStyle(
                          color: context.accentLight,
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _addExercises,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Exercise tile ──────────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final double sw;
  final VoidCallback onDelete;
  final void Function(int newCount) onSetsChanged;

  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.index,
    required this.sw,
    required this.onDelete,
    required this.onSetsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = exercise['photo_url'] as String?;
    final setsCount = (exercise['sets_count'] as int?) ?? 3;

    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.025),
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Row(
        children: [
          // index badge
          Container(
            width: sw * 0.08,
            height: sw * 0.08,
            decoration: BoxDecoration(
              color: context.accentBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: context.accentLight,
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.032,
                ),
              ),
            ),
          ),

          SizedBox(width: sw * 0.03),

          // photo
          ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.025),
            child: photoUrl != null && photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: sw * 0.12,
                    height: sw * 0.12,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _placeholder(context),
                  )
                : _placeholder(context),
          ),

          SizedBox(width: sw * 0.03),

          // name + muscle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] as String,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.036,
                  ),
                ),
                Text(
                  exercise['muscle_group'] as String,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: sw * 0.028,
                  ),
                ),
              ],
            ),
          ),

          // sets counter
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.01, vertical: sw * 0.005),
            decoration: BoxDecoration(
              color: context.rowBg,
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.015, vertical: sw * 0.01),
                  icon: Icon(Icons.remove_rounded,
                      color: context.textSecondary, size: sw * 0.04),
                  onPressed: setsCount > 1
                      ? () => onSetsChanged(setsCount - 1)
                      : null,
                ),
                Text(
                  '$setsCount',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.036,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.015, vertical: sw * 0.01),
                  icon: Icon(Icons.add_rounded,
                      color: context.textSecondary, size: sw * 0.04),
                  onPressed: () => onSetsChanged(setsCount + 1),
                ),
              ],
            ),
          ),

          SizedBox(width: sw * 0.02),

          // delete
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: sw * 0.045),
            ),
          ),

          SizedBox(width: sw * 0.015),

          // drag handle
          Icon(Icons.drag_handle_rounded,
              color: context.textMuted, size: sw * 0.045),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        width: sw * 0.12,
        height: sw * 0.12,
        decoration: BoxDecoration(
          color: context.rowBg,
          borderRadius: BorderRadius.circular(sw * 0.025),
        ),
        child: Icon(Icons.fitness_center_rounded,
            color: context.textMuted, size: sw * 0.05),
      );
}
