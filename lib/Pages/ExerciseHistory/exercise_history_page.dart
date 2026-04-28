import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseHistoryPage extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String userId;
  final bool isKg;

  const ExerciseHistoryPage({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.userId,
    required this.isKg,
  });

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  List<Map<String, dynamic>> _sets = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final we = await _supabase
        .from('workout_exercises')
        .select('id, workouts!inner(name, date, user_id)')
        .eq('exercise_id', widget.exerciseId)
        .eq('workouts.user_id', widget.userId);

    if ((we as List).isEmpty) {
      setState(() {
        _sets = [];
        _loading = false;
      });
      return;
    }

    final weIds = we.map((e) => e['id'] as String).toList();
    final weMap = {
      for (final w in we)
        w['id'] as String: w['workouts'] as Map<String, dynamic>
    };

    final sets = await _supabase
        .from('sets')
        .select('weight, reps, set_number, workout_exercise_id')
        .inFilter('workout_exercise_id', weIds)
        .order('weight', ascending: false);

    setState(() {
      _sets = (sets as List).map((s) {
        final workout = weMap[s['workout_exercise_id'] as String];
        return {
          'weight': (s['weight'] as num).toDouble(),
          'reps': s['reps'] as int,
          'set_number': s['set_number'] as int,
          'workout_name': workout?['name'] as String? ?? 'Workout',
          'workout_date': workout?['date'] as String?,
        };
      }).toList();
      _loading = false;
    });
  }

  String _fmt(double w) => widget.isKg
      ? '${w.toStringAsFixed(1)} kg'
      : '${(w * 2.205).toStringAsFixed(1)} lbs';

  String _fmtDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'All sets — best first',
              style: TextStyle(color: Colors.white54, fontSize: sw * 0.03),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _sets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_toggle_off,
                          color: Colors.white24, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'No sets logged yet for\n${widget.exerciseName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sw * 0.04),
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    final s = _sets[index];
                    final weight = s['weight'] as double;
                    final reps = s['reps'] as int;
                    final isPR = index == 0;

                    return Container(
                      margin: EdgeInsets.only(bottom: sw * 0.03),
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04, vertical: sw * 0.035),
                      decoration: BoxDecoration(
                        color: isPR
                            ? Colors.blue[800]
                            : const Color(0xFF2E4C8C),
                        borderRadius: BorderRadius.circular(14),
                        border: isPR
                            ? Border.all(color: Colors.blue[300]!, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          // rank badge
                          Container(
                            width: sw * 0.09,
                            height: sw * 0.09,
                            decoration: BoxDecoration(
                              color: isPR
                                  ? Colors.amber[600]
                                  : Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isPR
                                  ? Icon(Icons.emoji_events,
                                      color: Colors.white,
                                      size: sw * 0.045)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: sw * 0.032,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),

                          SizedBox(width: sw * 0.04),

                          // weight + reps
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fmt(weight),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: sw * 0.05,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$reps reps',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: sw * 0.035),
                                ),
                              ],
                            ),
                          ),

                          // date + workout name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _fmtDate(s['workout_date'] as String?),
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: sw * 0.03),
                              ),
                              Text(
                                s['workout_name'] as String,
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: sw * 0.028),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
