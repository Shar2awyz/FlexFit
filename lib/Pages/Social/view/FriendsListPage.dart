import 'package:flutter/material.dart';
import 'package:flex_fit/Pages/Components/app_route.dart';
import 'package:flex_fit/theme/app_colors.dart';

import '../SocialRepository.dart';
import '../model/friendship_model.dart';
import '../widgets/user_tile.dart';
import 'FriendProfilePage.dart';
import 'SearchUsersPage.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final _searchController = TextEditingController();
  final _socialRepo = SocialRepository();

  List<FriendshipModel> _allFriends = [];
  List<FriendshipModel> _filteredFriends = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final friends = await _socialRepo.getFriends(widget.currentUserId);
      if (mounted) {
        setState(() {
          _allFriends = friends;
          _filteredFriends = _filterList(friends, _searchController.text);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load friends. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredFriends = _filterList(_allFriends, _searchController.text);
    });
  }

  List<FriendshipModel> _filterList(List<FriendshipModel> list, String query) {
    if (query.isEmpty) return list;
    final lowercaseQuery = query.toLowerCase();
    return list.where((f) {
      final username = f.otherUser?.username.toLowerCase() ?? '';
      return username.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ref = MediaQuery.of(context).size.width.clamp(0.0, 480.0);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFriends,
              child: _buildContent(ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (ref * 0.04).clamp(12.0, 20.0),
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: context.appBarBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildContent(double ref) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: context.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFriends,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allFriends.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 64, color: context.textMuted),
              const SizedBox(height: 16),
              Text(
                'You don\'t have any friends yet.',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Find users to follow their progress!',
                style: TextStyle(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    appRoute((_) => SearchUsersPage(currentUserId: widget.currentUserId)),
                  ).then((_) => _loadFriends());
                },
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                label: const Text('Find Friends', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredFriends.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: context.textMuted),
              const SizedBox(height: 12),
              Text(
                'No friends match "${_searchController.text}"',
                style: TextStyle(color: context.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: (ref * 0.04).clamp(12.0, 20.0),
        vertical: 12,
      ),
      itemCount: _filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = _filteredFriends[index];
        final otherUser = friend.otherUser;
        if (otherUser == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: UserTile(
            user: otherUser,
            onTap: () {
              Navigator.push(
                context,
                appRoute(
                  (_) => FriendProfilePage(
                    currentUserId: widget.currentUserId,
                    profileUserId: otherUser.id,
                  ),
                ),
              ).then((_) => _loadFriends());
            },
          ),
        );
      },
    );
  }
}
