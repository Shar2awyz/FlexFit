import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialNotificationService extends ChangeNotifier {
  static const _lastVisitKey = 'last_social_visit';
  static const _pollInterval = Duration(seconds: 60);

  final String userId;
  final _supabase = Supabase.instance.client;

  bool _hasBadge = false;
  RealtimeChannel? _channel;
  Timer? _pollTimer;

  bool get hasBadge => _hasBadge;

  SocialNotificationService({required this.userId});

  Future<void> initialize() async {
    await _poll();
    _subscribeToFriendshipRealtime();
    _startPollingTimer();
  }

  // ── Polling (covers likes, comments, posts — no Realtime config needed) ──

  Future<void> _poll() async {
    if (_hasBadge) return;

    final prefs = await SharedPreferences.getInstance();
    final lastVisitStr = prefs.getString(_lastVisitKey);
    final since = lastVisitStr != null
        ? DateTime.parse(lastVisitStr)
        : DateTime.now().subtract(const Duration(days: 7));
    final sinceIso = since.toIso8601String();

    // Each check is independent — a failure in one doesn't block the others.
    if (await _hasPendingRequests()) { _setBadge(true); return; }
    if (await _hasNewFriendPosts(sinceIso)) { _setBadge(true); return; }
    if (await _hasNewLikesOrComments(sinceIso)) { _setBadge(true); return; }
  }

  Future<bool> _hasPendingRequests() async {
    try {
      final rows = await _supabase
          .from('friendships')
          .select('id')
          .eq('addressee_id', userId)
          .eq('status', 'pending')
          .limit(1);
      return (rows as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasNewFriendPosts(String sinceIso) async {
    try {
      final friendIds = await _fetchFriendIds();
      if (friendIds.isEmpty) return false;
      final rows = await _supabase
          .from('posts')
          .select('id')
          .inFilter('user_id', friendIds.toList())
          .gt('created_at', sinceIso)
          .limit(1);
      return (rows as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasNewLikesOrComments(String sinceIso) async {
    try {
      final myPostRows = await _supabase
          .from('posts')
          .select('id')
          .eq('user_id', userId);
      if ((myPostRows as List).isEmpty) return false;

      final myPostIds =
          myPostRows.map((e) => e['id'] as String).toList();

      // likes — try with created_at; if the column doesn't exist the query
      // throws and we fall through to the comments check.
      try {
        final likes = await _supabase
            .from('post_likes')
            .select('id')
            .inFilter('post_id', myPostIds)
            .neq('user_id', userId)
            .gt('created_at', sinceIso)
            .limit(1);
        if ((likes as List).isNotEmpty) return true;
      } catch (_) {
        // post_likes may not have created_at — fall through
      }

      final comments = await _supabase
          .from('post_comments')
          .select('id')
          .inFilter('post_id', myPostIds)
          .neq('user_id', userId)
          .gt('created_at', sinceIso)
          .limit(1);
      return (comments as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _startPollingTimer() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  // ── Realtime — only friendships (already works, no extra config needed) ──

  void _subscribeToFriendshipRealtime() {
    _channel?.unsubscribe();
    _channel = _supabase
        .channel('social_friend_notifs_$userId')
        // Someone sent you a request
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friendships',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'addressee_id',
            value: userId,
          ),
          callback: (_) => _setBadge(true),
        )
        // Someone accepted your request
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'friendships',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'requester_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord['status'] == 'accepted') _setBadge(true);
          },
        )
        .subscribe();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Set<String>> _fetchFriendIds() async {
    try {
      final asRequester = await _supabase
          .from('friendships')
          .select('addressee_id')
          .eq('requester_id', userId)
          .eq('status', 'accepted');

      final asAddressee = await _supabase
          .from('friendships')
          .select('requester_id')
          .eq('addressee_id', userId)
          .eq('status', 'accepted');

      return {
        ...(asRequester as List).map((e) => e['addressee_id'] as String),
        ...(asAddressee as List).map((e) => e['requester_id'] as String),
      };
    } catch (_) {
      return {};
    }
  }

  void _setBadge(bool value) {
    if (_hasBadge == value) return;
    _hasBadge = value;
    notifyListeners();
  }

  Future<void> markAsSeen() async {
    _setBadge(false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastVisitKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }
}
