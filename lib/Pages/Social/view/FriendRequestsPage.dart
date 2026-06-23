import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../viewmodel/friend_requests_cubit.dart';
import '../viewmodel/friend_requests_state.dart';

class FriendRequestsPage extends StatelessWidget {
  final String currentUserId;

  const FriendRequestsPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendRequestsCubit(
        SocialRepository(),
        userId: currentUserId,
      )..load(),
      child: const _FriendRequestsView(),
    );
  }
}

class _FriendRequestsView extends StatelessWidget {
  const _FriendRequestsView();

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        title: const Text('Friend Requests', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
        builder: (context, state) {
          if (state is FriendRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FriendRequestsError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: context.textMuted)),
            );
          }
          if (state is FriendRequestsLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 56, color: context.textMuted),
                    const SizedBox(height: 12),
                    Text('No pending requests',
                        style: TextStyle(color: context.textMuted, fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all((ref * 0.04).clamp(12.0, 20.0)),
              itemCount: state.requests.length,
              itemBuilder: (context, i) {
                final req = state.requests[i];
                final user = req.otherUser;
                final avatarSize = (ref * 0.12).clamp(44.0, 52.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all((ref * 0.035).clamp(10.0, 16.0)),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: context.cardShadow,
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: user?.imageUrl != null
                              ? Image.network(user!.imageUrl!, fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _placeholder(context, avatarSize))
                              : _placeholder(context, avatarSize),
                        ),
                      ),
                      SizedBox(width: (ref * 0.03).clamp(10.0, 14.0)),
                      Expanded(
                        child: Text(
                          user?.username ?? 'Unknown',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: (ref * 0.038).clamp(14.0, 16.0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _actionBtn(
                        context: context,
                        label: 'Accept',
                        color: context.accentLight,
                        onTap: () =>
                            context.read<FriendRequestsCubit>().accept(req.id),
                      ),
                      const SizedBox(width: 6),
                      _actionBtn(
                        context: context,
                        label: 'Decline',
                        color: context.textMuted,
                        onTap: () =>
                            context.read<FriendRequestsCubit>().reject(req.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _actionBtn({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.iconBg,
      child: Icon(Icons.person_rounded, color: context.textMuted),
    );
  }
}
