import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_fit/theme/app_colors.dart';


import '../../AddExercise/view/AddExercisePage.dart';
import '../../Components/app_route.dart';
import '../viewmodel/cubit/WorkoutBeginCubit.dart';
import '../viewmodel/cubit/WorkoutBeginState.dart';
import '../model/SetModel.dart';

class WorkoutBegin extends StatelessWidget {
  final String dayId;
  final String dayName;
  final bool resume;

  const WorkoutBegin({
    super.key,
    required this.dayId,
    required this.dayName,
    this.resume = false,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutBeginCubit>();
    if (!resume) {
      cubit.startWorkout(
        userId: Supabase.instance.client.auth.currentUser!.id,
        dayId: dayId,
        name: dayName,
      );
    }
    return _WorkoutBeginView(dayName: dayName);
  }
}

class _WorkoutBeginView extends StatefulWidget {
  final String dayName;
  const _WorkoutBeginView({required this.dayName});

  @override
  State<_WorkoutBeginView> createState() => _WorkoutBeginViewState();
}

class _WorkoutBeginViewState extends State<_WorkoutBeginView> {
  final Map<String, List<TextEditingController>> _weightCtrl = {};
  final Map<String, List<TextEditingController>> _repsCtrl = {};
  final Map<String, List<bool>> _completed = {};
  final Map<String, List<String>> _setIds = {};
  int _nextSetId = 0;
  final Set<String> _dismissedExerciseIds = {};

  Timer? _timer;
  String _elapsedTimeString = '00:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final cubit = context.read<WorkoutBeginCubit>();
      if (cubit.startTime != null) {
        final diff = DateTime.now().difference(cubit.startTime!);
        final hours = diff.inHours;
        final minutes = diff.inMinutes.remainder(60);
        final seconds = diff.inSeconds.remainder(60);

        final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
        final minutesStr = minutes.toString().padLeft(2, '0');
        final secondsStr = seconds.toString().padLeft(2, '0');

        setState(() {
          _elapsedTimeString = '$hoursStr$minutesStr:$secondsStr';
        });
      }
    });
  }

  void _initExercise(String id, List<SetModel> sets, {int plannedCount = 3}) {
    if (_weightCtrl.containsKey(id)) return;

    final completedCount = sets.length;
    final totalRows = completedCount > plannedCount ? completedCount : plannedCount;

    final weights = <TextEditingController>[];
    final reps = <TextEditingController>[];
    final completedList = <bool>[];
    final ids = <String>[];

    for (int i = 0; i < totalRows; i++) {
      ids.add('${id}_set_init_${_nextSetId++}');
      if (i < completedCount) {
        final setModel = sets[i];
        final wText = setModel.weight % 1 == 0
            ? setModel.weight.toInt().toString()
            : setModel.weight.toString();
        weights.add(TextEditingController(text: wText));
        reps.add(TextEditingController(text: setModel.reps.toString()));
        completedList.add(true);
      } else {
        weights.add(TextEditingController());
        reps.add(TextEditingController());
        completedList.add(false);
      }
    }

    _weightCtrl[id] = weights;
    _repsCtrl[id] = reps;
    _completed[id] = completedList;
    _setIds[id] = ids;
  }

  void _addSetFor(String id) {
    setState(() {
      _weightCtrl[id]!.add(TextEditingController());
      _repsCtrl[id]!.add(TextEditingController());
      _completed[id]!.add(false);
      _setIds[id]!.add('${id}_set_add_${_nextSetId++}');
    });
  }

  void _disposeExercise(String id) {
    for (final c in _weightCtrl.remove(id) ?? []) { c.dispose(); }
    for (final c in _repsCtrl.remove(id) ?? []) { c.dispose(); }
    _completed.remove(id);
    _setIds.remove(id);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final list in _weightCtrl.values) {
      for (final c in list) { c.dispose(); }
    }
    for (final list in _repsCtrl.values) {
      for (final c in list) { c.dispose(); }
    }
    super.dispose();
  }

  void _onSetDismissed(String exerciseId, int uiIndex) {
    final completedList = List<bool>.from(_completed[exerciseId]!);
    final wasCompleted = completedList[uiIndex];
    final setsListIndex =
        completedList.sublist(0, uiIndex).where((c) => c).length;

    _weightCtrl[exerciseId]![uiIndex].dispose();
    _repsCtrl[exerciseId]![uiIndex].dispose();

    setState(() {
      _weightCtrl[exerciseId]!.removeAt(uiIndex);
      _repsCtrl[exerciseId]!.removeAt(uiIndex);
      _completed[exerciseId]!.removeAt(uiIndex);
      _setIds[exerciseId]!.removeAt(uiIndex);
    });

    if (wasCompleted) {
      context.read<WorkoutBeginCubit>().removeSet(exerciseId, setsListIndex);
    }
  }

  Future<void> _onExerciseReplace(String exerciseId) async {
    final cubit = context.read<WorkoutBeginCubit>();
    final picked = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      appRoute((_) => const AddExercise(pickMode: true)),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    setState(() => _disposeExercise(exerciseId));
    await cubit.replaceExercise(exerciseId, picked.first);
  }

  Future<void> _onAddExercise() async {
    final cubit = context.read<WorkoutBeginCubit>();
    final picked = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      appRoute((_) => const AddExercise(pickMode: true)),
    );
    if (picked != null && picked.isNotEmpty && mounted) {
      await cubit.addExercises(picked);
    }
  }

  Future<void> _confirmDeleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text(
            'This will permanently delete this session and all logged sets.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final nav = Navigator.of(context);
    await context.read<WorkoutBeginCubit>().deleteWorkout();
    if (mounted) nav.pop();
  }

  Future<void> _onFinish() async {
    final cubit = context.read<WorkoutBeginCubit>();
    final nav = Navigator.of(context);

    final setCountsDiffer = cubit.exercises.any((ex) =>
        (_weightCtrl[ex.exerciseId]?.length ?? ex.plannedSets) !=
        ex.plannedSets);
    final hasChanges = cubit.hasStructuralChanges || setCountsDiffer;

    if (hasChanges && mounted) {
      final savePermanently = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save changes?'),
          content: const Text(
              'You made changes to this workout. Save them permanently to your split?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Just this once'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save permanently'),
            ),
          ],
        ),
      );
      if (savePermanently == true && mounted) {
        final setCounts = {
          for (final ex in cubit.exercises)
            ex.exerciseId:
                _weightCtrl[ex.exerciseId]?.length ?? ex.plannedSets,
        };
        await cubit.saveChangesToSplit(setCountsPerExercise: setCounts);
      }
    }

    await cubit.finishWorkout();
    if (!mounted) return;
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.workoutBg,
      appBar: AppBar(
        backgroundColor: context.workoutBg,
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
              'Log your sets',
              style: TextStyle(
                  color: context.textMuted, fontSize: sw * 0.028),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: sw * 0.055),
            tooltip: 'Delete workout',
            onPressed: _confirmDeleteWorkout,
          ),
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.025)),
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.045, vertical: sw * 0.02),
              ),
              onPressed: _onFinish,
              child: Text(
                'Finish',
                style: TextStyle(
                    fontSize: sw * 0.035, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<WorkoutBeginCubit, WorkoutBeginState>(
        builder: (context, state) {
          if (state is WorkoutBeginLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: context.accentLight));
          }

          if (state is WorkoutBeginLoaded) {
            final exercises = state.exercises;
            _dismissedExerciseIds.removeWhere((id) => !exercises.any((e) => e.exerciseId == id));
            for (final ex in exercises) {
              _initExercise(ex.exerciseId, ex.sets, plannedCount: ex.plannedSets);
            }

            return Column(
              children: [
                // ── stats bar ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      sw * 0.04, sw * 0.03, sw * 0.04, 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: sw * 0.035, horizontal: sw * 0.04),
                    decoration: BoxDecoration(
                      color: context.innerCard,
                      borderRadius: BorderRadius.circular(sw * 0.04),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Time',
                          value: _elapsedTimeString,
                          icon: Icons.timer_outlined,
                        ),
                        Container(
                            height: 32, width: 1, color: context.divider),
                        _StatItem(
                          label: 'Volume',
                          value: '${state.totalVolume.toInt()} kg',
                          icon: Icons.bar_chart_rounded,
                        ),
                        Container(
                            height: 32, width: 1, color: context.divider),
                        _StatItem(
                          label: 'Sets Done',
                          value: '${state.totalSets}',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sw * 0.03),

                // ── exercise list ─────────────────────────────────────────
                Expanded(
                  child: ReorderableListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: sw * 0.04),
                    buildDefaultDragHandles: true,
                    onReorder: (oldIndex, newIndex) {
                      context
                          .read<WorkoutBeginCubit>()
                          .reorderExercises(oldIndex, newIndex);
                    },
                    children: [
                      for (final entry in exercises.asMap().entries)
                        if (!_dismissedExerciseIds.contains(entry.value.exerciseId))
                          _buildExerciseCard(
                              context, sw, entry.key, entry.value),
                    ],
                  ),
                ),

                // ── add exercise ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: SizedBox(
                    width: double.infinity,
                    height: sw * 0.13,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: context.accent.withValues(alpha: 0.5),
                            width: 1.5),
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
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: _onAddExercise,
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, double sw, int index, dynamic ex) {
    return Dismissible(
      key: ValueKey(ex.exerciseId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sw * 0.05),
        margin: EdgeInsets.only(bottom: sw * 0.03),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(sw * 0.04),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: Colors.redAccent, size: sw * 0.055),
      ),
      onDismissed: (_) {
        setState(() {
          _dismissedExerciseIds.add(ex.exerciseId);
          _disposeExercise(ex.exerciseId);
        });
        context.read<WorkoutBeginCubit>().removeExercise(ex.exerciseId);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: sw * 0.03),
        child: _ExerciseCard(
          sw: sw,
          index: index,
          exercise: ex,
          weightControllers: _weightCtrl[ex.exerciseId]!,
          repsControllers: _repsCtrl[ex.exerciseId]!,
          completed: _completed[ex.exerciseId]!,
          setIds: _setIds[ex.exerciseId]!,
          onAddSet: () => _addSetFor(ex.exerciseId),
          onReplace: () => _onExerciseReplace(ex.exerciseId),
          onSetDismissed: (uiIndex) =>
              _onSetDismissed(ex.exerciseId, uiIndex),
          onComplete: (i, weight, reps) {
            setState(() => _completed[ex.exerciseId]![i] = true);
            context.read<WorkoutBeginCubit>().addSet(
                  exerciseIndex: index,
                  reps: reps,
                  weight: weight,
                );
          },
          onUncomplete: (i) {
            final completedList = List<bool>.from(_completed[ex.exerciseId]!);
            final setsListIndex =
                completedList.sublist(0, i).where((c) => c).length;
            setState(() => _completed[ex.exerciseId]![i] = false);
            context
                .read<WorkoutBeginCubit>()
                .removeSet(ex.exerciseId, setsListIndex);
          },
        ),
      ),
    );
  }
}

// ── Exercise card ──────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final dynamic exercise;
  final double sw;
  final int index;
  final List<TextEditingController> weightControllers;
  final List<TextEditingController> repsControllers;
  final List<bool> completed;
  final List<String> setIds;
  final VoidCallback onAddSet;
  final VoidCallback onReplace;
  final void Function(int uiIndex) onSetDismissed;
  final void Function(int index, double weight, int reps) onComplete;
  final void Function(int index) onUncomplete;

  const _ExerciseCard({
    required this.exercise,
    required this.sw,
    required this.index,
    required this.weightControllers,
    required this.repsControllers,
    required this.completed,
    required this.setIds,
    required this.onAddSet,
    required this.onReplace,
    required this.onSetDismissed,
    required this.onComplete,
    required this.onUncomplete,
  });

  @override
  Widget build(BuildContext context) {
    final ex = exercise;
    final completedCount = completed.where((c) => c).length;

    return Container(
      decoration: BoxDecoration(
        color: context.innerCard,
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: Column(
        children: [
          // ── header ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.04, sw * 0.035, sw * 0.02, sw * 0.01),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(sw * 0.025),
                  ),
                  child: Icon(Icons.fitness_center_rounded,
                      color: context.accentLight, size: sw * 0.05),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: sw * 0.04,
                        ),
                      ),
                      Text(
                        ex.muscleGroup ?? '',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.025, vertical: sw * 0.01),
                  decoration: BoxDecoration(
                    color: completedCount > 0
                        ? Colors.green.withValues(alpha: 0.15)
                        : context.iconBg,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    '$completedCount / ${weightControllers.length}',
                    style: TextStyle(
                      color: completedCount > 0
                          ? Colors.greenAccent
                          : context.textMuted,
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Replace exercise',
                  icon: Icon(Icons.swap_horiz_rounded,
                      color: context.textMuted, size: sw * 0.05),
                  onPressed: onReplace,
                ),
              ],
            ),
          ),

          // ── column headers ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04, vertical: sw * 0.01),
            child: Row(
              children: [
                SizedBox(
                  width: sw * 0.08,
                  child: Text('SET',
                      style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                ),
                Expanded(
                  child: Text('PREVIOUS',
                      style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: sw * 0.18,
                  child: Text('KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: sw * 0.18,
                  child: Text('REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                ),
                SizedBox(width: sw * 0.11),
              ],
            ),
          ),

          Divider(color: context.divider, height: 1),

          // ── set rows ──────────────────────────────────────────────────
          Column(
            children: List.generate(weightControllers.length, (i) {
              final hasPrev = i < ex.previousSets.length;
              final prevSet = hasPrev ? ex.previousSets[i] : null;
              final isSuggestion = hasPrev && prevSet!.reps >= 20;

              String prevText = hasPrev
                  ? '${prevSet!.weight % 1 == 0 ? prevSet.weight.toInt() : prevSet.weight}×${prevSet.reps}'
                  : '—';

              String weightHint = '0';
              String repsHint = '0';
              if (hasPrev) {
                if (isSuggestion) {
                  final raw = prevSet!.weight * 1.05;
                  final sugW = (raw * 2).round() / 2.0;
                  weightHint = sugW % 1 == 0
                      ? sugW.toInt().toString()
                      : sugW.toStringAsFixed(1);
                  repsHint = '6';
                } else {
                  final w = prevSet!.weight;
                  weightHint = w % 1 == 0 ? w.toInt().toString() : w.toStringAsFixed(1);
                  repsHint = prevSet.reps.toString();
                }
              }

              final isDone = completed[i];
              final setId = setIds[i];

              return Dismissible(
                key: ValueKey(setId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: sw * 0.04),
                  margin: EdgeInsets.symmetric(
                      horizontal: sw * 0.02, vertical: sw * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: sw * 0.055),
                ),
                onDismissed: (_) => onSetDismissed(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sw * 0.01),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green.withValues(alpha: 0.12)
                        : context.rowBg,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    border: isDone
                        ? Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                            width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: sw * 0.08,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isDone
                                ? Colors.greenAccent
                                : context.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.036,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          prevText,
                          style: TextStyle(
                              color: context.textMuted,
                              fontSize: sw * 0.032),
                        ),
                      ),
                      SizedBox(
                        width: sw * 0.18,
                        child: TextField(
                          controller: weightControllers[i],
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.textPrimary,
                              fontSize: sw * 0.036,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: weightHint,
                            hintStyle: TextStyle(
                                color: context.textHint,
                                fontSize: sw * 0.036),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sw * 0.18,
                        child: TextField(
                          controller: repsControllers[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.textPrimary,
                              fontSize: sw * 0.036,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: repsHint,
                            hintStyle: TextStyle(
                                color: context.textHint,
                                fontSize: sw * 0.036),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sw * 0.11,
                        child: GestureDetector(
                          onTap: () {
                            if (isDone) {
                              onUncomplete(i);
                            } else {
                              final weight = double.tryParse(
                                      weightControllers[i].text) ??
                                  0;
                              final reps = int.tryParse(
                                      repsControllers[i].text) ??
                                  0;
                              if (weight == 0 || reps == 0) return;
                              onComplete(i, weight, reps);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(sw * 0.02),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.green.withValues(alpha: 0.25)
                                  : context.accentBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: isDone
                                  ? Colors.greenAccent
                                  : context.accentLight,
                              size: sw * 0.045,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // ── add set ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.03, sw * 0.01, sw * 0.03, sw * 0.03),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: context.iconBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.025)),
                  padding:
                      EdgeInsets.symmetric(vertical: sw * 0.025),
                ),
                icon: Icon(Icons.add_rounded,
                    color: context.textSecondary, size: sw * 0.042),
                label: Text(
                  'Add Set',
                  style: TextStyle(
                      color: context.textSecondary,
                      fontSize: sw * 0.034),
                ),
                onPressed: onAddSet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat item ──────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Icon(icon, color: context.accentLight, size: sw * 0.048),
        SizedBox(height: sw * 0.01),
        Text(
          value,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.04,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              color: context.textMuted, fontSize: sw * 0.026),
        ),
      ],
    );
  }
}
