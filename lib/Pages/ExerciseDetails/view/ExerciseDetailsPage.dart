import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled6/theme/app_colors.dart';
import '../ExerciseDetailsRepository.dart';
import '../model/ExerciseDetailModel.dart';
import '../viewmodel/ExerciseDetailsViewModel.dart';
import 'ExerciseComponent.dart';

class ExerciseDetails extends StatefulWidget {
  final String exerciseId;
  final String userid;

  const ExerciseDetails({
    super.key,
    required this.userid,
    required this.exerciseId,
  });

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  late final ExerciseDetailsViewModel _vm;
  late Future<List<ExerciseDetailModel>> _future;

  @override
  void initState() {
    super.initState();
    _vm = ExerciseDetailsViewModel(ExerciseDetailsRepository());
    _future = _vm.loadExercises(widget.exerciseId);
  }

  Future<void> _openVideo(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
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
        toolbarHeight: sw * 0.18,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseId,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: sw * 0.048,
              ),
            ),
            Text(
              'Tap any card to watch tutorial',
              style: TextStyle(color: context.textMuted, fontSize: sw * 0.028),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<ExerciseDetailModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: context.accentLight));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading exercises',
                  style:
                      TextStyle(color: context.textSecondary, fontSize: sw * 0.04)),
            );
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center,
                      color: context.textMuted, size: sw * 0.15),
                  SizedBox(height: sw * 0.04),
                  Text('No exercises found',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: sw * 0.04)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(sw * 0.05),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return Padding(
                padding: EdgeInsets.only(bottom: sw * 0.04),
                child: GestureDetector(
                  onTap: () => _openVideo(ex.videoUrl ?? ''),
                  child: ExerciseComponent(
                    name: ex.name,
                    description: ex.muscleGroup,
                    equipment: ex.equipment,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
