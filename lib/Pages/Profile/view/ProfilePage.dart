import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_fit/Pages/AddExercise/view/AddExercisePage.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/Pages/Components/CongratsPRDialog.dart';
import 'package:flex_fit/Pages/Social/view/FriendsListPage.dart';
import 'package:flex_fit/Pages/ExerciseHistory/view/ExerciseHistoryPage.dart';
import 'package:flex_fit/theme/app_colors.dart';
import 'package:flex_fit/services/settings_service.dart';
import '../ProfileRepository.dart';
import '../model/TrackedExerciseModel.dart';
import '../viewmodel/ProfileViewModel.dart';
import 'SettingsPage.dart';

class Profile extends StatelessWidget {
  final String userid;

  const Profile({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProfileViewModel(ProfileRepository(), userId: userid)..loadAll(),
      child: _ProfileView(userid: userid),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String userid;
  const _ProfileView({required this.userid});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _picker = ImagePicker();
  bool get isKg => context.read<SettingsService>().isKg;

  Future<void> _pickAvatar(ProfileViewModel vm) async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    await vm.uploadAvatar(File(xFile.path));
  }

  Future<void> _addTracked(ProfileViewModel vm) async {
    final picked = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      appRoute((_) => const AddExercise(pickMode: true)),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    await vm.addTracked(picked);
  }

  Future<void> _setGoal(
      BuildContext context, ProfileViewModel vm, TrackedExerciseModel t) async {
    final current = t.goalWeightKg;
    final ctrl = TextEditingController(
        text: current != null ? current.toStringAsFixed(1) : '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Goal for ${t.name}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Target weight in ${isKg ? 'kg' : 'lbs'}',
            suffixText: isKg ? 'kg' : 'lbs',
          ),
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

    if (confirmed != true || !mounted) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val == null) return;
    final goalKg = isKg ? val : val / 2.205;
    final prevProgress = t.progress;
    await vm.setGoal(t.id, goalKg);

    if (mounted) {
      final updatedT = vm.trackedExercises.firstWhere((element) => element.id == t.id);
      final newProgress = updatedT.progress;
      if ((prevProgress == null || prevProgress < 1.0) && newProgress != null && newProgress >= 1.0) {
        await CongratsPRDialog.show(context, [t.name]);
      }
    }
  }

  Future<void> _editWeight(
      BuildContext context, ProfileViewModel vm, double currentKg) async {
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Weight',
            suffixText: isKg ? 'kg' : 'lbs',
          ),
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

    if (confirmed != true || !mounted) return;
    final val = double.tryParse(ctrl.text.trim());
    if (val == null) return;
    await vm.updateBodyWeight(isKg ? val : val / 2.205);
  }

  String _fmt(double w) => isKg
      ? '${w.toStringAsFixed(1)} kg'
      : '${(w * 2.205).toStringAsFixed(1)} lbs';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    context.watch<SettingsService>();
    final sw = MediaQuery.of(context).size.width;

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
              Icons.settings_rounded,
              color: context.textPrimary,
            ),
            onPressed: () {
              final profileVm = context.read<ProfileViewModel>();
              Navigator.push(
                context,
                appRoute((_) => ChangeNotifierProvider.value(
                      value: profileVm,
                      child: SettingsPage(userid: widget.userid),
                    )),
              ).then((_) {
                if (mounted) {
                  profileVm.loadAll();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: vm.isLoading
          ? Center(
              child: Lottie.asset(
                  'animation/Icon gym for Sporttler.json',
                  width: 100,
                  height: 100))
          : vm.error != null
              ? Center(
                  child: Text(vm.error!,
                      style: TextStyle(color: context.textSecondary)))
              : vm.user == null
                  ? Center(
                      child: Text('No data',
                          style: TextStyle(color: context.textSecondary)))
                  : RefreshIndicator(
                      onRefresh: vm.loadAll,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                            sw * 0.04, sw * 0.04, sw * 0.04, sw * 0.08),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatar(context, vm, sw),
                            SizedBox(height: sw * 0.025),
                            Text(
                              vm.user!.username,
                              style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: sw * 0.055,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: sw * 0.01),
                            Text(
                              vm.user!.memberSince,
                              style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: sw * 0.033),
                            ),
                            SizedBox(height: sw * 0.05),
                            _buildStats(context, vm, sw),
                            SizedBox(height: sw * 0.04),
                            _buildWeightCard(context, vm, sw),
                            SizedBox(height: sw * 0.06),
                            _buildPRHeader(context, vm, sw),
                            SizedBox(height: sw * 0.03),
                            _buildPRList(context, vm, sw),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildAvatar(
      BuildContext context, ProfileViewModel vm, double sw) {
    final r = sw * 0.13;
    final photoUrl = vm.user?.imageUrl;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _pickAvatar(vm),
          child: CircleAvatar(
            radius: r,
            backgroundColor: Colors.white24,
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: r * 2,
                      height: r * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, _, _) =>
                          Icon(Icons.person, size: r, color: Colors.white),
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
            child:
                Icon(Icons.camera_alt, size: sw * 0.04, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
      BuildContext context, ProfileViewModel vm, double sw) {
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
          _statCell(context, 'Workouts', '${vm.workoutCount}',
              Icons.fitness_center_rounded, sw),
          Container(width: 1, height: sw * 0.1, color: context.divider),
          _statCell(context, 'Total Sets', '${vm.totalSets}',
              Icons.check_circle_outline_rounded, sw),
          Container(width: 1, height: sw * 0.1, color: context.divider),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                appRoute((_) => FriendsListPage(currentUserId: widget.userid)),
              ).then((_) {
                if (mounted) {
                  vm.loadAll();
                }
              });
            },
            child: _statCell(context, 'Friends', '${vm.friendsCount}',
                Icons.people_alt_rounded, sw),
          ),
        ],
      ),
    );
  }

  Widget _statCell(BuildContext context, String label, String value,
      IconData icon, double sw) {
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
            style: TextStyle(
                color: context.textSecondary, fontSize: sw * 0.03)),
      ],
    );
  }

  Widget _buildWeightCard(
      BuildContext context, ProfileViewModel vm, double sw) {
    final weightKg = vm.user?.weightKg ?? 0.0;
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
                  _unitChip(context, 'KG', isKg,
                      () => context.read<SettingsService>().setWeightUnit(true), sw),
                  SizedBox(width: sw * 0.02),
                  _unitChip(context, 'LBS', !isKg,
                      () => context.read<SettingsService>().setWeightUnit(false), sw),
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
                onTap: () => _editWeight(context, vm, weightKg),
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
                      Icon(Icons.edit_rounded,
                          color: context.textSecondary, size: sw * 0.035),
                      SizedBox(width: sw * 0.01),
                      Text('Edit',
                          style: TextStyle(
                              color: context.textSecondary,
                              fontSize: sw * 0.03)),
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

  Widget _unitChip(BuildContext context, String label, bool selected,
      VoidCallback onTap, double sw) {
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

  Widget _buildPRHeader(
      BuildContext context, ProfileViewModel vm, double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Exercise PRs',
            style: TextStyle(
                color: context.textPrimary,
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => _addTracked(vm),
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
                    style:
                        TextStyle(color: Colors.white, fontSize: sw * 0.033)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPRList(
      BuildContext context, ProfileViewModel vm, double sw) {
    if (vm.trackedExercises.isEmpty) {
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
            Icon(Icons.bar_chart_rounded,
                color: context.textMuted, size: sw * 0.12),
            SizedBox(height: sw * 0.025),
            Text(
              'Tap "Track" to add the lifts\nyou want to follow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.textSecondary, fontSize: sw * 0.035),
            ),
          ],
        ),
      );
    }

    return Column(
      children: vm.trackedExercises
          .map((t) => _buildTrackedTile(context, vm, t, sw))
          .toList(),
    );
  }

  Widget _buildTrackedTile(BuildContext context, ProfileViewModel vm,
      TrackedExerciseModel t, double sw) {
    final progress = t.progress;

    return Dismissible(
      key: ValueKey(t.id),
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
      onDismissed: (_) => vm.removeTracked(t.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          appRoute((_) => ExerciseHistoryPage(
                exerciseId: t.exerciseId,
                exerciseName: t.name,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name,
                            style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: sw * 0.038),
                            overflow: TextOverflow.ellipsis),
                        Text(t.muscle,
                            style: TextStyle(
                                color: context.textSecondary,
                                fontSize: sw * 0.03)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        t.maxWeightKg != null
                            ? _fmt(t.maxWeightKg!)
                            : 'No data',
                        style: TextStyle(
                            color: t.maxWeightKg != null
                                ? context.textPrimary
                                : context.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.04),
                      ),
                      Text('best lift',
                          style: TextStyle(
                              color: context.textMuted,
                              fontSize: sw * 0.028)),
                      SizedBox(height: sw * 0.015),
                      GestureDetector(
                        onTap: () => _setGoal(context, vm, t),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025, vertical: sw * 0.01),
                          decoration: BoxDecoration(
                            color: t.goalWeightKg != null
                                ? Colors.green[800]
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.goalWeightKg != null
                                ? 'Goal: ${_fmt(t.goalWeightKg!)}'
                                : 'Set goal',
                            style: TextStyle(
                                color: t.goalWeightKg != null
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
