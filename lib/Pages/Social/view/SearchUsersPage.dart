import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled6/Pages/Components/app_route.dart';
import 'package:untitled6/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../viewmodel/search_users_cubit.dart';
import '../viewmodel/search_users_state.dart';
import '../widgets/user_tile.dart';
import 'FriendProfilePage.dart';

class SearchUsersPage extends StatelessWidget {
  final String currentUserId;

  const SearchUsersPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SearchUsersCubit(SocialRepository(), currentUserId: currentUserId),
      child: _SearchUsersView(currentUserId: currentUserId),
    );
  }
}

class _SearchUsersView extends StatefulWidget {
  final String currentUserId;
  const _SearchUsersView({required this.currentUserId});

  @override
  State<_SearchUsersView> createState() => _SearchUsersViewState();
}

class _SearchUsersViewState extends State<_SearchUsersView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        title: const Text('Search Users', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all((ref * 0.04).clamp(12.0, 20.0)),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: context.textPrimary),
              onChanged: (q) =>
                  context.read<SearchUsersCubit>().search(q),
              decoration: InputDecoration(
                hintText: 'Search by username…',
                hintStyle: TextStyle(color: context.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: context.textMuted),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: context.textMuted),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchUsersCubit>().search('');
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
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchUsersCubit, SearchUsersState>(
              builder: (context, state) {
                if (state is SearchUsersInitial) {
                  return Center(
                    child: Text('Search for people to connect with',
                        style: TextStyle(color: context.textMuted)),
                  );
                }
                if (state is SearchUsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SearchUsersError) {
                  return Center(
                    child: Text(state.message,
                        style: TextStyle(color: context.textMuted)),
                  );
                }
                if (state is SearchUsersLoaded) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Text('No users found',
                          style: TextStyle(color: context.textMuted)),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: (ref * 0.04).clamp(12.0, 20.0)),
                    itemCount: state.users.length,
                    itemBuilder: (context, i) {
                      final user = state.users[i];
                      return UserTile(
                        user: user,
                        onTap: () => Navigator.push(
                          context,
                          appRoute(
                            (_) => FriendProfilePage(
                              currentUserId: widget.currentUserId,
                              profileUserId: user.id,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.textMuted,
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
