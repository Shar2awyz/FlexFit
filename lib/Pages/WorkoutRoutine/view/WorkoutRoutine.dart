import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../../AddExercise/view/AddExercisePage.dart';
import '../../Components/app_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../WorkoutBegin/view/WorkoutBegin.dart';
import '../../WorkoutBegin/viewmodel/cubit/WorkoutBeginCubit.dart';
import 'ModifyDayPage.dart';
import '../model/SplitDay.dart';
import '../model/ExerciseModel.dart';
import '../viewmodel/WorkoutViewModel.dart';

class WorkoutRoutine extends StatefulWidget {
  final String splitId;
  final String? splitname;

  const WorkoutRoutine({super.key, required this.splitId, this.splitname});

  @override
  State<WorkoutRoutine> createState() => _WorkoutRoutineState();
}

class _WorkoutRoutineState extends State<WorkoutRoutine> {
  final vm = WorkoutViewModel();
  late Future<List<SplitDay>> future;
  final Map<String, Future<List<ExerciseModel>>> _exercisesFuture = {};
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    future = vm.loadRoutine(widget.splitId);
  }

  Future<List<ExerciseModel>> _loadExercises(String dayId) =>
      _exercisesFuture.putIfAbsent(
          dayId, () => vm.loadExercisesWithSets(dayId));

  void _reload() => setState(() {
        future = vm.loadRoutine(widget.splitId);
        _exercisesFuture.clear();
      });

  Future<void> _renameDay(String dayId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Day'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Day name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (confirmed != true) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;
    await _supabase.from('split_days').update({'name': name}).eq('id', dayId);
    _reload();
  }

  Future<void> _deleteDay(String dayId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Day'),
        content: const Text(
            'This will permanently remove this day and all its exercises.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await _supabase
        .from('split_exercises')
        .delete()
        .eq('split_day_id', dayId);
    await _supabase.from('split_days').delete().eq('id', dayId);
    _reload();
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
              widget.splitname ?? 'Workout Routine',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: sw * 0.048,
              ),
            ),
            Text(
              'Your training days',
              style: TextStyle(color: context.textMuted, fontSize: sw * 0.028),
            ),
          ],
        ),
        toolbarHeight: sw * 0.18,
      ),
      body: FutureBuilder<List<SplitDay>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator(color: context.accentLight));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString(),
                  style: TextStyle(color: context.textSecondary)),
            );
          }

          final days = snapshot.data ?? [];

          return Column(
            children: [
              // ── Add day button ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    sw * 0.04, 0, sw * 0.04, sw * 0.02),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      appRoute((_) =>
                          AddExercise(splitId: widget.splitId)),
                    );
                    setState(
                        () => future = vm.loadRoutine(widget.splitId));
                  },
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
                          'Add Routine to Program',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.038,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Day list ───────────────────────────────────────────────
              Expanded(
                child: days.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: context.textMuted, size: sw * 0.15),
                            SizedBox(height: sw * 0.04),
                            Text(
                              'No training days yet',
                              style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: sw * 0.04),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04, vertical: sw * 0.01),
                        itemCount: days.length,
                        itemBuilder: (context, index) =>
                            _DayCard(
                              day: days[index],
                              sw: sw,
                              loadExercises: _loadExercises,
                              onRename: () =>
                                  _renameDay(days[index].id, days[index].name),
                              onDelete: () => _deleteDay(days[index].id),
                              onModify: () async {
                                await Navigator.push(
                                  context,
                                  appRoute((_) => ModifyDayPage(
                                        splitDayId: days[index].id,
                                        dayName: days[index].name,
                                      )),
                                );
                                _reload();
                              },
                            ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Day card ───────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final SplitDay day;
  final double sw;
  final Future<List<ExerciseModel>> Function(String) loadExercises;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onModify;

  const _DayCard({
    required this.day,
    required this.sw,
    required this.loadExercises,
    required this.onRename,
    required this.onDelete,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.035),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(sw * 0.045),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04, vertical: sw * 0.01),
          childrenPadding: EdgeInsets.only(bottom: sw * 0.02),
          title: Row(
            children: [
              // icon badge
              Container(
                width: sw * 0.13,
                height: sw * 0.13,
                decoration: BoxDecoration(
                  color: context.accentBg,
                  borderRadius: BorderRadius.circular(sw * 0.032),
                ),
                child: Icon(Icons.calendar_today_rounded,
                    color: context.accentLight, size: sw * 0.055),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.name,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${day.exercises.length} exercises',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: sw * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              // start button
              GestureDetector(
                onTap: () {
                  final activeWorkoutCubit = context.read<WorkoutBeginCubit>();
                  if (activeWorkoutCubit.isWorkoutInProgress) {
                    if (activeWorkoutCubit.splitDayId == day.id) {
                      Navigator.push(
                        context,
                        appRoute((_) => WorkoutBegin(
                              dayId: day.id,
                              dayName: day.name,
                              resume: true,
                            )),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Workout in progress'),
                          content: Text(
                              'A workout "${activeWorkoutCubit.workoutName}" is already in progress. Do you want to discard it and start "${day.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final nav = Navigator.of(context);
                                await activeWorkoutCubit.deleteWorkout();
                                nav.push(
                                  appRoute((_) => WorkoutBegin(
                                        dayId: day.id,
                                        dayName: day.name,
                                      )),
                                );
                              },
                              child: const Text(
                                'Discard & Start',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      appRoute((_) => WorkoutBegin(
                            dayId: day.id,
                            dayName: day.name,
                          )),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: context.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: sw * 0.05),
                ),
              ),
              SizedBox(width: sw * 0.02),
              // menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: context.textMuted, size: sw * 0.05),
                color: context.cardAlt,
                onSelected: (value) {
                  if (value == 'modify') onModify();
                  if (value == 'rename') onRename();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'modify',
                    child: Row(children: [
                      Icon(Icons.tune_rounded,
                          size: sw * 0.045, color: context.textPrimary),
                      SizedBox(width: sw * 0.02),
                      Text('Modify exercises',
                          style: TextStyle(color: context.textPrimary)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(children: [
                      Icon(Icons.edit_rounded,
                          size: sw * 0.045, color: context.textPrimary),
                      SizedBox(width: sw * 0.02),
                      Text('Rename',
                          style: TextStyle(color: context.textPrimary)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: sw * 0.045, color: Colors.redAccent),
                      SizedBox(width: sw * 0.02),
                      const Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          children: [
            FutureBuilder<List<ExerciseModel>>(
              future: loadExercises(day.id),
              builder: (context, exSnap) {
                if (exSnap.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: context.accentLight)),
                  );
                }

                final exercises = exSnap.data ?? [];

                if (exercises.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Text('No exercises added yet',
                        style: TextStyle(
                            color: context.textMuted, fontSize: sw * 0.034)),
                  );
                }

                return Column(
                  children: exercises.map((exercise) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: sw * 0.04, vertical: sw * 0.015),
                      padding: EdgeInsets.all(sw * 0.035),
                      decoration: BoxDecoration(
                        color: context.rowBg,
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            exercise.name,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: sw * 0.036,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            exercise.muscleGroup,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: sw * 0.028,
                            ),
                          ),
                          children: [
                            if (exercise.sets == null ||
                                exercise.sets!.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: sw * 0.03,
                                    left: sw * 0.02),
                                child: Text(
                                  'No sets from last session',
                                  style: TextStyle(
                                      color: context.textMuted,
                                      fontSize: sw * 0.03),
                                ),
                              )
                            else
                              ...exercise.sets!.map((set) => Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: sw * 0.01,
                                        horizontal: sw * 0.02),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: sw * 0.07,
                                          height: sw * 0.07,
                                          decoration: BoxDecoration(
                                            color: context.accentBg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${set.number}',
                                              style: TextStyle(
                                                  color: context.accentLight,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: sw * 0.028),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: sw * 0.03),
                                        Text(
                                          '${set.weight} kg  ×  ${set.reps} reps',
                                          style: TextStyle(
                                            color: context.textPrimary,
                                            fontSize: sw * 0.034,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
