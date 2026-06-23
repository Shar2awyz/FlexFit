import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';
import '../ExerciseHistoryRepository.dart';
import '../model/ExerciseSetRecord.dart';
import '../viewmodel/ExerciseHistoryViewModel.dart';

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
  late final ExerciseHistoryViewModel _vm;
  late Future<List<ExerciseSetRecord>> _future;

  @override
  void initState() {
    super.initState();
    _vm = ExerciseHistoryViewModel(ExerciseHistoryRepository());
    _future = _vm.loadHistory(widget.exerciseId, widget.userId);
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
              widget.exerciseName,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'All sets — best first',
              style: TextStyle(color: context.textMuted, fontSize: sw * 0.03),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<ExerciseSetRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: context.accentLight));
          }

          final sets = snapshot.data ?? [];

          if (sets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_toggle_off,
                      color: context.textMuted, size: sw * 0.14),
                  SizedBox(height: sw * 0.03),
                  Text(
                    'No sets logged yet for\n${widget.exerciseName}',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: context.textSecondary, fontSize: sw * 0.038),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04, vertical: sw * 0.04),
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final s = sets[index];
              final isPR = index == 0;

              return Container(
                margin: EdgeInsets.only(bottom: sw * 0.03),
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sw * 0.035),
                decoration: BoxDecoration(
                  color: isPR ? context.accent : context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: isPR
                      ? Border.all(color: context.accentLight, width: 1.5)
                      : Border.all(color: context.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: sw * 0.09,
                      height: sw * 0.09,
                      decoration: BoxDecoration(
                        color: isPR ? Colors.amber[600] : context.rowBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isPR
                            ? Icon(Icons.emoji_events,
                                color: Colors.white, size: sw * 0.045)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                    color: context.textMuted,
                                    fontSize: sw * 0.032,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.formattedWeight(widget.isKg),
                            style: TextStyle(
                                color: context.textPrimary,
                                fontSize: sw * 0.05,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${s.reps} reps',
                            style: TextStyle(
                                color: context.textSecondary,
                                fontSize: sw * 0.035),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          s.formattedDate,
                          style: TextStyle(
                              color: context.textMuted, fontSize: sw * 0.03),
                        ),
                        Text(
                          s.workoutName,
                          style: TextStyle(
                              color: context.textMuted, fontSize: sw * 0.028),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
