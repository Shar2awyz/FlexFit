import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled6/theme/app_colors.dart';

import 'package:untitled6/Pages/Exercises.dart';
import 'package:untitled6/Pages/Profile.dart';
import 'package:untitled6/Pages/WorkoutSplit/workout_split_page.dart';
import 'package:untitled6/Pages/WorkoutRoutine/view/WorkoutRoutine.dart';
import 'package:untitled6/Pages/premadeworkout/premadeworkout.dart';
import 'Components/CustomBottomNavBar.dart';
import 'Components/app_route.dart';
import 'Dashboard/View/Dashboard.dart';
import 'Start Workout/routineCard.dart';

class StartWorkout extends StatefulWidget {
  final String userid;

  const StartWorkout({super.key, required this.userid});

  @override
  State<StartWorkout> createState() => _StartWorkoutState();
}

class _StartWorkoutState extends State<StartWorkout> {
  late Future<List<dynamic>> _splitsFuture;
  late Future<List<Map<String, dynamic>>> _premadeFuture;

  Future<List<dynamic>> _loadSplits(String userId) async {
    return await Supabase.instance.client
        .from('workout_splits')
        .select('id, name, split_days(id, name, day_order)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> _loadPremade() async {
    final data = await Supabase.instance.client
        .from('premade_splits')
        .select('id, name, photo_url');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _renameSplit(List<dynamic> splits, int index) async {
    final controller =
        TextEditingController(text: splits[index]['name'] as String? ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Split'),
        content: TextField(
          controller: controller,
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
    final name = controller.text.trim();
    if (name.isEmpty) return;
    await Supabase.instance.client
        .from('workout_splits')
        .update({'name': name}).eq('id', splits[index]['id'] as String);
    setState(() => splits[index]['name'] = name);
  }

  ImageProvider _img(dynamic v) {
    if (v == null) return const AssetImage('images/download.jpg');
    final s = v.toString();
    if (s.startsWith('data:image')) {
      return MemoryImage(base64Decode(s.split(',').last));
    }
    if (s.startsWith('http')) return NetworkImage(s);
    return const AssetImage('images/download.jpg');
  }

  @override
  void initState() {
    super.initState();
    _splitsFuture = _loadSplits(widget.userid);
    _premadeFuture = _loadPremade();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    const int currentIndex = 1;

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
              style: TextStyle(
                color: context.textMuted,
                fontSize: sw * 0.032,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
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
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── New Split card ─────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                appRoute((_) => WorkoutSplitPage(userid: widget.userid)),
              ),
              child: Container(
                padding: EdgeInsets.all(sw * 0.045),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.accent,
                      context.accentLight,
                    ],
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

            // ── Premade programs section ────────────────────────────────
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _premadeFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final splits = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      height: sw * 0.38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: splits.length,
                        itemBuilder: (context, index) {
                          final split = splits[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              appRoute((_) => PremadeWorkout(
                                  splitid: split['id'])),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(right: sw * 0.035),
                              width: sw * 0.38,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(sw * 0.04),
                                boxShadow: context.cardShadow,
                                image: DecorationImage(
                                  image: _img(split['photo_url']),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.35),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(sw * 0.03),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    split['name'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: sw * 0.034,
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
                );
              },
            ),

            // ── My Routines section ────────────────────────────────────
            Text(
              'My Routines',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.042,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: sw * 0.03),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _splitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                        'animation/Icon gym for Sporttler.json',
                        width: sw * 0.25,
                        height: sw * 0.25,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: context.textSecondary)),
                    );
                  }

                  final splits = snapshot.data ?? [];

                  if (splits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                    );
                  }

                  return ListView.builder(
                    itemCount: splits.length,
                    itemBuilder: (context, index) {
                      final split = splits[index];
                      return Dismissible(
                        key: Key(split['id'].toString()),
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
                        onDismissed: (_) async {
                          final removed = splits[index];
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => splits.removeAt(index));
                          await Supabase.instance.client
                              .from('workout_splits')
                              .delete()
                              .eq('id', removed['id']);
                          messenger.showSnackBar(
                            SnackBar(
                                content:
                                    Text('${removed['name']} deleted')),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            appRoute((_) => WorkoutRoutine(
                                  splitId: split['id'],
                                  splitname: split['name'],
                                )),
                          ),
                          child: routineCard(
                            icon: Icons.fitness_center_rounded,
                            title: split['name'] as String? ?? '',
                            subtitle:
                                '${(split['split_days'] as List).length} days',
                            trailing: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded,
                                  color: context.textMuted,
                                  size: sw * 0.05),
                              color: context.cardAlt,
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _renameSplit(splits, index);
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
