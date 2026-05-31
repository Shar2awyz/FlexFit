import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled6/Pages/Components/app_route.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import '../viewmodel/add_by_email_cubit.dart';
import '../viewmodel/add_by_email_state.dart';
import 'FriendProfilePage.dart';

class AddByEmailPage extends StatelessWidget {
  final String currentUserId;

  const AddByEmailPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AddByEmailCubit(SocialRepository(), currentUserId: currentUserId),
      child: _AddByEmailView(currentUserId: currentUserId),
    );
  }
}

class _AddByEmailView extends StatefulWidget {
  final String currentUserId;
  const _AddByEmailView({required this.currentUserId});

  @override
  State<_AddByEmailView> createState() => _AddByEmailViewState();
}

class _AddByEmailViewState extends State<_AddByEmailView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Friend by Email',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all((ref * 0.05).clamp(16.0, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your friend's email address",
              style: TextStyle(
                color: context.textSecondary,
                fontSize: (ref * 0.038).clamp(13.0, 15.0),
              ),
            ),
            SizedBox(height: (ref * 0.04).clamp(14.0, 20.0)),
            _emailField(context, ref),
            SizedBox(height: (ref * 0.04).clamp(14.0, 20.0)),
            _searchButton(context, ref),
            SizedBox(height: (ref * 0.06).clamp(20.0, 28.0)),
            BlocBuilder<AddByEmailCubit, AddByEmailState>(
              builder: (context, state) => _resultSection(context, ref, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailField(BuildContext context, double ref) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(context),
      style: TextStyle(color: context.textPrimary),
      decoration: InputDecoration(
        hintText: 'friend@example.com',
        hintStyle: TextStyle(color: context.textMuted),
        prefixIcon: Icon(Icons.email_outlined, color: context.textMuted),
        suffixIcon: _emailController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: context.textMuted),
                onPressed: () {
                  _emailController.clear();
                  context.read<AddByEmailCubit>().reset();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: context.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.accentLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _searchButton(BuildContext context, double ref) {
    return BlocBuilder<AddByEmailCubit, AddByEmailState>(
      builder: (context, state) {
        final isSearching = state is AddByEmailSearching;
        return SizedBox(
          width: double.infinity,
          height: (ref * 0.13).clamp(48.0, 56.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accentLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isSearching ? null : () => _search(context),
            icon: isSearching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(
              isSearching ? 'Searching…' : 'Find Friend',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: (ref * 0.04).clamp(14.0, 16.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resultSection(
    BuildContext context,
    double ref,
    AddByEmailState state,
  ) {
    if (state is AddByEmailInitial) return const SizedBox.shrink();

    if (state is AddByEmailSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AddByEmailNotFound) {
      return _emptyResult(context, ref);
    }

    if (state is AddByEmailError) {
      return _errorResult(context, ref, state.message);
    }

    if (state is AddByEmailFound) {
      return _userCard(context, ref, state);
    }

    return const SizedBox.shrink();
  }

  Widget _emptyResult(BuildContext context, double ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: (ref * 0.15).clamp(54.0, 68.0),
            color: context.textMuted,
          ),
          SizedBox(height: (ref * 0.03).clamp(10.0, 14.0)),
          Text(
            'No user found with that email.',
            style: TextStyle(
              color: context.textMuted,
              fontSize: (ref * 0.038).clamp(13.0, 15.0),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: (ref * 0.02).clamp(6.0, 10.0)),
          Text(
            'Make sure the email is correct.',
            style: TextStyle(
              color: context.textHint,
              fontSize: (ref * 0.032).clamp(11.0, 13.0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _errorResult(BuildContext context, double ref, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.redAccent.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text(
            'Something went wrong.',
            style: TextStyle(
              color: context.textMuted,
              fontSize: (ref * 0.038).clamp(13.0, 15.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(
    BuildContext context,
    double ref,
    AddByEmailFound state,
  ) {
    final user = state.user;
    final avatarSize = (ref * 0.16).clamp(56.0, 72.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((ref * 0.05).clamp(16.0, 22.0)),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              appRoute(
                (_) => FriendProfilePage(
                  currentUserId: widget.currentUserId,
                  profileUserId: user.id,
                ),
              ),
            ),
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: user.imageUrl != null
                        ? Image.network(
                            user.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _avatarPlaceholder(context, avatarSize),
                          )
                        : _avatarPlaceholder(context, avatarSize),
                  ),
                ),
                SizedBox(height: (ref * 0.03).clamp(10.0, 14.0)),
                Text(
                  user.username,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: (ref * 0.048).clamp(17.0, 20.0),
                  ),
                ),
                SizedBox(height: (ref * 0.015).clamp(4.0, 8.0)),
                Text(
                  'Tap to view profile',
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: (ref * 0.03).clamp(10.0, 12.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: (ref * 0.05).clamp(16.0, 22.0)),
          _actionButton(context, ref, state),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    double ref,
    AddByEmailFound state,
  ) {
    switch (state.status) {
      case FriendshipStatus.none:
        return _btn(
          context: context,
          ref: ref,
          label: 'Add Friend',
          icon: Icons.person_add_rounded,
          color: context.accentLight,
          onTap: () =>
              context.read<AddByEmailCubit>().sendRequest(state.user.id),
        );
      case FriendshipStatus.pending:
        return _btn(
          context: context,
          ref: ref,
          label: 'Request Sent',
          icon: Icons.hourglass_top_rounded,
          color: context.textMuted,
          onTap: () =>
              context.read<AddByEmailCubit>().cancelRequest(state.user.id),
        );
      case FriendshipStatus.accepted:
        return _btn(
          context: context,
          ref: ref,
          label: 'Already Friends',
          icon: Icons.people_rounded,
          color: Colors.green,
          onTap: null,
        );
      case FriendshipStatus.rejected:
        return _btn(
          context: context,
          ref: ref,
          label: 'Add Friend',
          icon: Icons.person_add_rounded,
          color: context.accentLight,
          onTap: () =>
              context.read<AddByEmailCubit>().sendRequest(state.user.id),
        );
    }
  }

  Widget _btn({
    required BuildContext context,
    required double ref,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: (ref * 0.032).clamp(11.0, 14.0),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: onTap != null ? 0.14 : 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: onTap != null ? 0.5 : 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: (ref * 0.04).clamp(14.0, 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(
        Icons.person_rounded,
        color: context.textMuted,
        size: size * 0.5,
      ),
    );
  }

  void _search(BuildContext context) {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<AddByEmailCubit>().findByEmail(email);
  }
}
