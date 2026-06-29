import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flex_fit/theme/app_colors.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/Pages/WorkoutRoutine/view/WorkoutRoutine.dart';
import 'package:flex_fit/Pages/premadeworkout/view/PremadeWorkoutPage.dart';
import 'package:flex_fit/Pages/WorkoutSplit/view/WorkoutSplitPage.dart';
import '../StartWorkoutRepository.dart';
import '../model/SplitSummaryModel.dart';
import '../viewmodel/StartWorkoutViewModel.dart';
import 'RoutineCard.dart';

class StartWorkout extends StatelessWidget {
  final String userid;

  const StartWorkout({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          StartWorkoutViewModel(StartWorkoutRepository(), userId: userid)
            ..loadAll(),
      child: _StartWorkoutView(userid: userid),
    );
  }
}

class _StartWorkoutView extends StatelessWidget {
  final String userid;
  const _StartWorkoutView({required this.userid});

  ImageProvider _img(String? v) {
    if (v == null) return const AssetImage('images/download.jpg');
    if (v.startsWith('data:image')) {
      return MemoryImage(base64Decode(v.split(',').last));
    }
    if (v.startsWith('http')) return NetworkImage(v);
    return const AssetImage('images/download.jpg');
  }

  Future<void> _renameSplit(
      BuildContext context, StartWorkoutViewModel vm, SplitSummaryModel split) async {
    final ctrl = TextEditingController(text: split.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Split'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Split name'),
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
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    vm.renameSplit(split.id, name);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StartWorkoutViewModel>();
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: sw * 0.2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Workout',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.065,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Choose a split or start fresh',
              style: TextStyle(color: context.textMuted, fontSize: sw * 0.032),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            sw * 0.04, 0, sw * 0.04, sw * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Create New Split button ────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                appRoute((_) => WorkoutSplitPage(userid: userid)),
              ),
              child: Container(
                padding: EdgeInsets.all(sw * 0.045),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.accent, context.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(sw * 0.045),
                  boxShadow: [
                    BoxShadow(
                      color: context.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Icon(Icons.edit_rounded,
                          color: Colors.white, size: sw * 0.065),
                    ),
                    SizedBox(width: sw * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Split',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.042,
                          ),
                        ),
                        SizedBox(height: sw * 0.01),
                        Text(
                          'Design your custom program',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: sw * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: sw * 0.05),

            // ── Featured Programs ─────────────────────────────────────
            if (vm.premadeSplits.isNotEmpty) ...[
              Text(
                'Featured Programs',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sw * 0.03),
              SizedBox(
                height: sw * 0.30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.premadeSplits.length,
                  itemBuilder: (context, index) {
                    final split = vm.premadeSplits[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        appRoute((_) =>
                            PremadeWorkout(splitid: split.id)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(right: sw * 0.035),
                        width: sw * 0.30,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(sw * 0.04),
                          boxShadow: context.cardShadow,
                          image: DecorationImage(
                            image: _img(split.photoUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.35),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(sw * 0.025),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              split.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: sw * 0.030,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sw * 0.05),
            ],

            // ── My Routines ────────────────────────────────────────────
            Text(
              'My Routines',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.042,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sw * 0.03),

            if (vm.isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.1),
                  child: Lottie.asset(
                    'animation/Icon gym for Sporttler.json',
                    width: sw * 0.25,
                    height: sw * 0.25,
                  ),
                ),
              )
            else if (vm.splits.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.1),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_rounded,
                        color: context.textMuted, size: sw * 0.14),
                    SizedBox(height: sw * 0.03),
                    Text(
                      'No routines yet',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sw * 0.01),
                    Text(
                      'Create your first split above',
                      style: TextStyle(
                          color: context.textMuted,
                          fontSize: sw * 0.032),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.splits.length,
                itemBuilder: (context, index) {
                  final split = vm.splits[index];
                  return Dismissible(
                    key: Key(split.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: sw * 0.05),
                      margin: EdgeInsets.only(bottom: sw * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(sw * 0.04),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: sw * 0.055),
                    ),
                    onDismissed: (_) {
                      final messenger =
                          ScaffoldMessenger.of(context);
                      final name = split.name;
                      vm.deleteSplit(split.id);
                      messenger.showSnackBar(
                          SnackBar(content: Text('$name deleted')));
                    },
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        appRoute((_) => WorkoutRoutine(
                              splitId: split.id,
                              splitname: split.name,
                            )),
                      ),
                      child: RoutineCard(
                        icon: Icons.fitness_center_rounded,
                        title: split.name,
                        subtitle: '${split.dayCount} days',
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded,
                              color: context.textMuted,
                              size: sw * 0.05),
                          color: context.cardAlt,
                          onSelected: (value) {
                            if (value == 'rename') {
                              _renameSplit(context, vm, split);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(children: [
                                Icon(Icons.edit_rounded,
                                    color: context.textPrimary,
                                    size: sw * 0.045),
                                SizedBox(width: sw * 0.02),
                                Text('Rename',
                                    style: TextStyle(
                                        color: context.textPrimary)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
