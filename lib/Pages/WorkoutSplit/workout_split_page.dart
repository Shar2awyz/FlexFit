import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../AddExercise/AddExercise.dart';
import '../Components/CustomBottomNavBar.dart';
import '../Components/app_route.dart';
import '../Dashboard/View/Dashboard.dart';
import '../Exercises.dart';
import '../Profile.dart';
import '../Start_Workout.dart';

class WorkoutSplitPage extends StatefulWidget {
  final String userid;

  const WorkoutSplitPage({super.key, required this.userid});

  @override
  State<WorkoutSplitPage> createState() => _WorkoutSplitPageState();
}

class _WorkoutSplitPageState extends State<WorkoutSplitPage> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController(text: 'My Split');

  String? _splitId;
  List<Map<String, dynamic>> _days = [];
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadDays() async {
    if (_splitId == null) return;
    setState(() => _loading = true);
    final data = await _supabase
        .from('split_days')
        .select('id, name, day_order')
        .eq('split_id', _splitId!)
        .order('day_order');
    setState(() {
      _days = List<Map<String, dynamic>>.from(data as List);
      _loading = false;
    });
  }

  Future<void> _addSplitDay() async {
    if (_splitId == null) {
      final name = _nameController.text.trim().isEmpty
          ? 'My Split'
          : _nameController.text.trim();
      final res = await _supabase
          .from('workout_splits')
          .insert({'user_id': widget.userid, 'name': name})
          .select('id')
          .single();
      setState(() => _splitId = res['id'] as String);
    }
    if (!mounted) return;
    await Navigator.push(
        context, appRoute((_) => AddExercise(splitId: _splitId!)));
    await _loadDays();
  }

  Future<void> _deleteDay(String dayId, int index) async {
    setState(() => _days.removeAt(index));
    await _supabase.from('split_exercises').delete().eq('split_day_id', dayId);
    await _supabase.from('split_days').delete().eq('id', dayId);
  }

  void _onNavTap(int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, appRoute((_) => Dashboard(userid: widget.userid)));
        break;
      case 2:
        Navigator.pushReplacement(
            context, appRoute((_) => Exercises(userid: widget.userid)));
        break;
      case 3:
        Navigator.pushReplacement(
            context, appRoute((_) => Profile(userid: widget.userid)));
        break;
    }
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
        title: TextField(
          controller: _nameController,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: sw * 0.048,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Split Name',
            hintStyle: TextStyle(color: context.textMuted),
            border: InputBorder.none,
          ),
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavBar(currentIndex: 1, onTap: _onNavTap),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add Day button ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.04, sw * 0.03, sw * 0.04, sw * 0.02),
            child: GestureDetector(
              onTap: _addSplitDay,
              child: Container(
                height: sw * 0.13,
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(sw * 0.035),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: Colors.white, size: sw * 0.055),
                    SizedBox(width: sw * 0.025),
                    Text(
                      'Add New Split Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sw * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Days list ──────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        color: context.accentLight))
                : _days.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center_rounded,
                                color: context.textMuted, size: sw * 0.16),
                            SizedBox(height: sw * 0.04),
                            Text(
                              _splitId == null
                                  ? 'Tap "Add New Split Day" to begin'
                                  : 'No days yet',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: sw * 0.038,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04, vertical: sw * 0.01),
                        itemCount: _days.length,
                        itemBuilder: (context, index) {
                          final day = _days[index];
                          return Dismissible(
                            key: ValueKey(day['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  EdgeInsets.only(right: sw * 0.05),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(sw * 0.04),
                              ),
                              child: Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: sw * 0.055),
                            ),
                            onDismissed: (_) =>
                                _deleteDay(day['id'] as String, index),
                            child: Container(
                              margin:
                                  EdgeInsets.only(bottom: sw * 0.025),
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.04,
                                  vertical: sw * 0.035),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius:
                                    BorderRadius.circular(sw * 0.04),
                                border: Border.all(
                                    color: context.border, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: sw * 0.12,
                                    height: sw * 0.12,
                                    decoration: BoxDecoration(
                                      color: context.accentBg,
                                      borderRadius: BorderRadius.circular(
                                          sw * 0.03),
                                    ),
                                    child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: context.accentLight,
                                        size: sw * 0.05),
                                  ),
                                  SizedBox(width: sw * 0.03),
                                  Text(
                                    day['name'] as String,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: sw * 0.038,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // ── Done button ────────────────────────────────────────────────
          if (_splitId != null && _days.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.04, 0, sw * 0.04, sw * 0.02),
              child: SizedBox(
                width: double.infinity,
                height: sw * 0.13,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.035)),
                  ),
                  icon: Icon(Icons.check_rounded, size: sw * 0.055),
                  label: Text(
                    'Done — Go to Workouts',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      appRoute((_) =>
                          StartWorkout(userid: widget.userid)),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
