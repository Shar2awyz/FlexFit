import 'package:flutter/material.dart';
import 'package:untitled6/Pages/Dashboard/Repository.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_detail_model.dart';
import 'package:untitled6/Pages/Dashboard/model/workout_history_model.dart';
import 'package:untitled6/theme/app_colors.dart';
import '../viewmodel/WorkoutDetailViewModel.dart';

class WorkoutDetailPage extends StatefulWidget {
  final WorkoutHistoryModel workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  late final WorkoutDetailViewModel _vm;
  late Future<WorkoutSessionDetail> _future;

  @override
  void initState() {
    super.initState();
    _vm = WorkoutDetailViewModel(DashboardRepository());
    _future = _vm.loadDetail(widget.workout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.deepBg, context.pageBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: FutureBuilder<WorkoutSessionDetail>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: context.accentLight),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load workout details.',
                          style: TextStyle(
                              color: context.textMuted, fontSize: 14),
                        ),
                      );
                    }
                    return _buildBody(context, snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workout.name,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.workout.formattedDate} · ${widget.workout.formattedDuration}',
                  style:
                      TextStyle(color: context.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutSessionDetail detail) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: detail.exercises.length,
      itemBuilder: (context, index) =>
          _buildExerciseCard(context, detail.exercises[index]),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseDetail exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fitness_center,
                      color: context.accentLight, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exercise.muscleGroup.isNotEmpty)
                        Text(
                          exercise.muscleGroup,
                          style: TextStyle(
                              color: context.textMuted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${exercise.sets.length} sets',
                  style: TextStyle(
                      color: context.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (exercise.sets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text('SET',
                        style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text('WEIGHT',
                        style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text('REPS',
                        style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ...exercise.sets.map((set) => _buildSetRow(context, set)),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, SetDetail set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: context.rowBg,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '${set.setNumber}',
                style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Text(
              set.weight == 0
                  ? 'BW'
                  : '${set.weight % 1 == 0 ? set.weight.toInt() : set.weight} kg',
              style: TextStyle(color: context.textPrimary, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              '${set.reps} reps',
              style: TextStyle(color: context.textPrimary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
