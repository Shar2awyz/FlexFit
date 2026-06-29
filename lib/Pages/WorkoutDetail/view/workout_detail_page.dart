import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/Pages/Dashboard/Repository.dart';
import 'package:flex_fit/Pages/Dashboard/model/workout_detail_model.dart';
import 'package:flex_fit/Pages/Dashboard/model/workout_history_model.dart';
import 'package:flex_fit/theme/app_colors.dart';
import '../viewmodel/WorkoutDetailViewModel.dart';

class WorkoutDetailPage extends StatefulWidget {
  final WorkoutHistoryModel workout;
  final String? ownerName;
  final String? ownerImageUrl;

  const WorkoutDetailPage({
    super.key,
    required this.workout,
    this.ownerName,
    this.ownerImageUrl,
  });

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  late final WorkoutDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WorkoutDetailViewModel(DashboardRepository())..loadDetail(widget.workout);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WorkoutDetailViewModel>(
        builder: (context, vm, child) {
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
                      child: Builder(
                        builder: (context) {
                          if (vm.isLoading && vm.detail == null) {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: context.accentLight),
                            );
                          }
                          if (vm.error != null && vm.detail == null) {
                            return Center(
                              child: Text(
                                'Failed to load workout details.',
                                style: TextStyle(
                                    color: context.textMuted, fontSize: 14),
                              ),
                            );
                          }
                          if (vm.detail == null) {
                            return Center(
                              child: Text(
                                'No details found.',
                                style: TextStyle(
                                    color: context.textMuted, fontSize: 14),
                              ),
                            );
                          }
                          return _buildBody(context, vm.detail!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                if (widget.ownerName != null) ...[
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: widget.ownerImageUrl != null &&
                                  widget.ownerImageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.ownerImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _avatarPlaceholder(context, 24),
                                )
                              : _avatarPlaceholder(context, 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.ownerName!,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
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
    final summary = detail.progressSummary;
    final volumeDiff = summary?['volume_diff_pct'] as num?;
    final exerciseProgress = summary?['exercise_progress'] as List?;
    final hasProgress = (volumeDiff != null && volumeDiff > 0) || (exerciseProgress != null && exerciseProgress.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Notes Section
        if (detail.notes != null && detail.notes!.isNotEmpty) ...[
          _buildSectionHeader(context, 'Notes'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border, width: 1),
              boxShadow: context.cardShadow,
            ),
            child: Text(
              detail.notes!,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],

        // Progress Section
        if (hasProgress) ...[
          _buildSectionHeader(context, 'Progress Highlights'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exerciseProgress != null)
                  ...exerciseProgress.map((item) {
                    final name = item['name'] as String;
                    final diff = item['diff'] as num;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: context.textPrimary, fontSize: 13),
                                children: [
                                  TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: ' +${diff % 1 == 0 ? diff.toInt() : diff} kg',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: ' since last session'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                if (volumeDiff != null && volumeDiff > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: context.textPrimary, fontSize: 13),
                              children: [
                                const TextSpan(text: 'Total volume '),
                                TextSpan(
                                  text: '+$volumeDiff%',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],

        _buildSectionHeader(context, 'Exercises'),
        ...detail.exercises.map((ex) {
          final isPr = exerciseProgress != null && exerciseProgress.any((item) => item['name'] == ex.name);
          return _buildExerciseCard(context, ex, isPr: isPr);
        }),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseDetail exercise, {bool isPr = false}) {
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              exercise.name,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPr) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'PR',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  Widget _avatarPlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(Icons.person, color: context.textMuted, size: size * 0.6),
    );
  }
}
