import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AddExercise/AddExercise.dart';
import 'Components/CustomBottomNavBar.dart';
import 'Components/app_route.dart';
import 'Dashboard/View/Dashboard.dart';
import 'ExerciseHistory/exercise_history_page.dart';
import 'Exercises.dart';
import 'Start_Workout.dart';
import '../services/services.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';

class Profile extends StatefulWidget {
  final String userid;
  const Profile({super.key, required this.userid});

  @override
  State<Profile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  bool isKg = true;
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _userData;
  int _workoutCount = 0;
  int _totalSets = 0;
  List<Map<String, dynamic>> _tracked = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ── data ──────────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([_loadUser(), _loadStats()]);
      await _loadTracked();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadUser() async {
    _userData = await _supabase
        .from('Users')
        .select()
        .eq('id', widget.userid)
        .single();
  }

  Future<void> _loadStats() async {
    final workouts = await _supabase
        .from('workouts')
        .select('id')
        .eq('user_id', widget.userid);
    _workoutCount = (workouts as List).length;

    final we = await _supabase
        .from('workout_exercises')
        .select('id, workouts!inner(user_id)')
        .eq('workouts.user_id', widget.userid);

    if ((we as List).isNotEmpty) {
      final ids = we.map((e) => e['id'] as String).toList();
      final sets = await _supabase
          .from('sets')
          .select('id')
          .inFilter('workout_exercise_id', ids);
      _totalSets = (sets as List).length;
    }
  }

  Future<void> _loadTracked() async {
    final rows = await _supabase
        .from('tracked_exercises')
        .select('id, exercise_id, goal_weight, exercises(name, muscle_group)')
        .eq('user_id', widget.userid);

    final list = <Map<String, dynamic>>[];
    for (final row in rows as List) {
      final ex = row['exercises'] as Map<String, dynamic>;
      final maxW = await _getMaxWeight(row['exercise_id'] as String);
      list.add({
        'id': row['id'],
        'exercise_id': row['exercise_id'],
        'name': ex['name'] ?? '',
        'muscle': ex['muscle_group'] ?? '',
        'maxWeight': maxW,
        'goalWeight': (row['goal_weight'] as num?)?.toDouble(),
      });
    }
    _tracked = list;
  }

  Future<double?> _getMaxWeight(String exerciseId) async {
    try {
      final we = await _supabase
          .from('workout_exercises')
          .select('id, workouts!inner(user_id)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.user_id', widget.userid);

      if ((we as List).isEmpty) return null;
      final ids = we.map((e) => e['id'] as String).toList();

      final sets = await _supabase
          .from('sets')
          .select('weight')
          .inFilter('workout_exercise_id', ids);

      if ((sets as List).isEmpty) return null;
      return (sets as List)
          .map((s) => (s['weight'] as num).toDouble())
          .reduce((a, b) => a > b ? a : b);
    } catch (_) {
      return null;
    }
  }

  // ── actions ──────────────────────────────────────────────────────────────

  Future<void> _addTracked() async {
    final picked = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      appRoute((_) => const AddExercise(pickMode: true)),
    );
    if (picked == null || picked.isEmpty || !mounted) return;

    for (final ex in picked) {
      if (_tracked.any((t) => t['exercise_id'] == ex['id'])) continue;
      await _supabase.from('tracked_exercises').upsert({
        'user_id': widget.userid,
        'exercise_id': ex['id'] as String,
      });
    }

    setState(() => _loading = true);
    await _loadTracked();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _removeTracked(String id) async {
    setState(() => _tracked.removeWhere((t) => t['id'] == id));
    await _supabase.from('tracked_exercises').delete().eq('id', id);
  }

  Future<void> _setGoal(Map<String, dynamic> t) async {
    final current = t['goalWeight'] as double?;
    final ctrl = TextEditingController(
        text: current != null ? current.toStringAsFixed(1) : '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Goal for ${t['name']}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Target weight in ${isKg ? 'kg' : 'lbs'}',
            suffixText: isKg ? 'kg' : 'lbs',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    double? goal = double.tryParse(ctrl.text.trim());
    if (goal == null) return;
    // If user entered lbs, convert to kg for storage
    final goalKg = isKg ? goal : goal / 2.205;

    await _supabase
        .from('tracked_exercises')
        .update({'goal_weight': goalKg.round()})
        .eq('id', t['id'] as String);

    setState(() => t['goalWeight'] = goalKg);
  }

  Future<void> _editWeight(double currentKg) async {
    final ctrl = TextEditingController(
        text: isKg
            ? currentKg.toStringAsFixed(1)
            : (currentKg * 2.205).toStringAsFixed(1));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Body Weight'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Weight',
            suffixText: isKg ? 'kg' : 'lbs',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val == null) return;
    final valKg = isKg ? val : val / 2.205;

    await _supabase
        .from('Users')
        .update({'weight(kg)': valKg.round()})
        .eq('id', widget.userid);

    await _loadUser();
    if (mounted) setState(() {});
  }

  Future<void> _pickAvatar() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    await supa().uploadImage(File(xFile.path), widget.userid);
    await _loadUser();
    if (mounted) setState(() {});
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  String _memberSince() {
    final raw = _userData?['created_at'] as String?;
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Member since ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _fmt(double w) => isKg
      ? '${w.toStringAsFixed(1)} kg'
      : '${(w * 2.205).toStringAsFixed(1)} lbs';

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeService = context.read<ThemeService>();

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
              color: context.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: context.textPrimary,
            ),
            tooltip: themeService.isDark ? 'Light mode' : 'Dark mode',
            onPressed: themeService.toggle,
          ),
          SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 3) return;
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                  context, appRoute((_) => Dashboard(userid: widget.userid)));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  appRoute((_) => StartWorkout(userid: widget.userid)));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, appRoute((_) => Exercises(userid: widget.userid)));
              break;
          }
        },
      ),
      body: _loading
          ? Center(
              child: Lottie.asset('animation/Icon gym for Sporttler.json',
                  width: 100, height: 100))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: TextStyle(color: context.textSecondary)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_userData == null) {
      return Center(
          child: Text('No data',
              style: TextStyle(color: context.textSecondary)));
    }

    final sw = MediaQuery.of(context).size.width;
    final p = sw * 0.04;

    final photoUrl = _userData!['image_url'] as String?;
    final username = _userData!['username'] as String? ?? 'User';
    final weightRaw = _userData!['weight(kg)'];
    final weightKg = (weightRaw is num ? weightRaw.toDouble() : 0.0);

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(p, p, p, p * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── avatar ───────────────────────────────────────────────────
            _buildAvatar(photoUrl, sw),
            SizedBox(height: sw * 0.025),
            Text(
              username,
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: sw * 0.01),
            Text(
              _memberSince(),
              style: TextStyle(color: context.textSecondary, fontSize: sw * 0.033),
            ),

            SizedBox(height: sw * 0.05),

            // ── stats ─────────────────────────────────────────────────
            _buildStats(sw),

            SizedBox(height: sw * 0.04),

            // ── body weight ───────────────────────────────────────────
            _buildWeightCard(weightKg, sw),

            SizedBox(height: sw * 0.06),

            // ── PR tracker ────────────────────────────────────────────
            _buildPRHeader(sw),
            SizedBox(height: sw * 0.03),
            _buildPRList(sw),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, double sw) {
    final r = sw * 0.13;
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: CircleAvatar(
            radius: r,
            backgroundColor: Colors.white24,
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: r * 2,
                      height: r * 2,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Icons.person,
                          size: r, color: Colors.white),
                    )
                  : Icon(Icons.person, size: r, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: sw * 0.04,
            backgroundColor: Colors.blue[600],
            child: Icon(Icons.camera_alt,
                size: sw * 0.04, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.045),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCell('Workouts', '$_workoutCount', Icons.fitness_center_rounded, sw),
          Container(width: 1, height: sw * 0.1, color: context.divider),
          _statCell('Total Sets', '$_totalSets',
              Icons.check_circle_outline_rounded, sw),
        ],
      ),
    );
  }

  Widget _statCell(
      String label, String value, IconData icon, double sw) {
    return Column(
      children: [
        Icon(icon, color: context.accentLight, size: sw * 0.045),
        SizedBox(height: sw * 0.015),
        Text(value,
            style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.06,
                fontWeight: FontWeight.bold)),
        SizedBox(height: sw * 0.005),
        Text(label,
            style: TextStyle(color: context.textSecondary, fontSize: sw * 0.03)),
      ],
    );
  }

  Widget _buildWeightCard(double weightKg, double sw) {
    final display = isKg
        ? weightKg.toStringAsFixed(1)
        : (weightKg * 2.205).toStringAsFixed(1);
    final unit = isKg ? 'kg' : 'lbs';

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body Weight',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: sw * 0.04)),
              Row(
                children: [
                  _unitChip('KG', isKg, () => setState(() => isKg = true),
                      sw),
                  SizedBox(width: sw * 0.02),
                  _unitChip('LBS', !isKg,
                      () => setState(() => isKg = false), sw),
                ],
              ),
            ],
          ),
          SizedBox(height: sw * 0.035),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.monitor_weight_outlined,
                  color: context.textSecondary, size: sw * 0.07),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$display $unit',
                    style: TextStyle(
                        color: context.textPrimary,
                        fontSize: sw * 0.085,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _editWeight(weightKg),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sw * 0.015),
                  decoration: BoxDecoration(
                    color: context.rowBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: context.textSecondary, size: sw * 0.035),
                      SizedBox(width: sw * 0.01),
                      Text('Edit',
                          style: TextStyle(
                              color: context.textSecondary, fontSize: sw * 0.03)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _unitChip(
      String label, bool selected, VoidCallback onTap, double sw) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.035, vertical: sw * 0.015),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.rowBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : context.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: sw * 0.033),
        ),
      ),
    );
  }

  Widget _buildPRHeader(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Exercise PRs',
            style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: _addTracked,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.035, vertical: sw * 0.018),
            decoration: BoxDecoration(
              color: context.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: sw * 0.038),
                SizedBox(width: sw * 0.012),
                Text('Track',
                    style: TextStyle(
                        color: Colors.white, fontSize: sw * 0.033)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPRList(double sw) {
    if (_tracked.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: sw * 0.07, horizontal: sw * 0.04),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, color: context.textMuted, size: sw * 0.12),
            SizedBox(height: sw * 0.025),
            Text(
              'Tap "Track" to add the lifts\nyou want to follow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, fontSize: sw * 0.035),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _tracked.map((t) => _buildTrackedTile(t, sw)).toList(),
    );
  }

  Widget _buildTrackedTile(Map<String, dynamic> t, double sw) {
    final maxW = t['maxWeight'] as double?;
    final goalW = t['goalWeight'] as double?;
    final hasData = maxW != null;

    double? progress;
    if (hasData && goalW != null && goalW > 0) {
      progress = (maxW / goalW).clamp(0.0, 1.0);
    }

    return Dismissible(
      key: ValueKey(t['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sw * 0.05),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _removeTracked(t['id'] as String),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          appRoute((_) => ExerciseHistoryPage(
                exerciseId: t['exercise_id'] as String,
                exerciseName: t['name'] as String,
                userId: widget.userid,
                isKg: isKg,
              )),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: sw * 0.025),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.border, width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // icon
                  Container(
                    width: sw * 0.11,
                    height: sw * 0.11,
                    decoration: BoxDecoration(
                      color: context.accentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.fitness_center_rounded,
                        color: context.accentLight, size: sw * 0.05),
                  ),

                  SizedBox(width: sw * 0.035),

                  // name + muscle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['name'] as String,
                            style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: sw * 0.038),
                            overflow: TextOverflow.ellipsis),
                        Text(t['muscle'] as String,
                            style: TextStyle(
                                color: context.textSecondary,
                                fontSize: sw * 0.03)),
                      ],
                    ),
                  ),

                  // best lift + goal button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        hasData ? _fmt(maxW!) : 'No data',
                        style: TextStyle(
                            color: hasData ? context.textPrimary : context.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.04),
                      ),
                      Text('best lift',
                          style: TextStyle(
                              color: context.textMuted,
                              fontSize: sw * 0.028)),
                      SizedBox(height: sw * 0.015),
                      GestureDetector(
                        onTap: () => _setGoal(t),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025,
                              vertical: sw * 0.01),
                          decoration: BoxDecoration(
                            color: goalW != null
                                ? Colors.green[800]
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            goalW != null
                                ? 'Goal: ${_fmt(goalW)}'
                                : 'Set goal',
                            style: TextStyle(
                                color: goalW != null
                                    ? Colors.greenAccent[100]
                                    : Colors.white54,
                                fontSize: sw * 0.028,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: sw * 0.02),
                  Icon(Icons.chevron_right_rounded,
                      color: context.textMuted, size: sw * 0.05),
                ],
              ),

              // progress bar (only when goal is set)
              if (progress != null) ...[
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: sw * 0.018,
                          backgroundColor: context.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? Colors.amber
                                : context.accentLight,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                          color: progress >= 1.0
                              ? Colors.amber
                              : context.textSecondary,
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
