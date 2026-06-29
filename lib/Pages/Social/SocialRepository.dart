import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/comment_model.dart';
import 'model/feed_item.dart';
import 'model/friendship_model.dart';
import 'model/post_model.dart';
import 'model/social_user_model.dart';
import 'model/story_model.dart';

class SocialRepository {
  final _supabase = Supabase.instance.client;

  static const _postSelect =
      '*, Users(id, username, image_url), post_likes(count), post_comments(count), post_reposts(count), workouts(*, workout_exercises(id, order_index, exercises(name, muscle_group), sets(reps, weight, set_number)))';

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<List<FeedItem>> getFeed({
    required String userId,
    int page = 0,
    int pageSize = 15,
  }) async {
    final friendIds = await _getAcceptedFriendIds(userId);
    final visibleUserIds = [...friendIds, userId];

    final likedIds = await _getLikedPostIds(userId);
    final savedIds = await _getSavedPostIds(userId);
    final repostedIds = await _getRepostedPostIds(userId);

    // Original posts from self + friends
    final postsData = await _supabase
        .from('posts')
        .select(_postSelect)
        .inFilter('user_id', visibleUserIds)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    final postItems = (postsData as List).map((json) {
      final map = json as Map<String, dynamic>;
      return FeedItem(
        post: PostModel.fromJson(
          map,
          isLiked: likedIds.contains(map['id']),
          isSaved: savedIds.contains(map['id']),
          isReposted: repostedIds.contains(map['id']),
        ),
        sortDate: DateTime.parse(map['created_at'] as String),
      );
    }).toList();

    // Reposts made by friends
    final repostItems = <FeedItem>[];
    if (friendIds.isNotEmpty) {
      try {
        final repostsRaw = await _supabase
            .from('post_reposts')
            .select('post_id, user_id, created_at, Users(id, username, image_url)')
            .inFilter('user_id', friendIds)
            .order('created_at', ascending: false)
            .range(page * pageSize, (page + 1) * pageSize - 1);

        if ((repostsRaw as List).isNotEmpty) {
          final repostedPostIds = repostsRaw
              .map((e) => e['post_id'] as String)
              .toSet()
              .toList();

          final repostedPostsData = await _supabase
              .from('posts')
              .select(_postSelect)
              .inFilter('id', repostedPostIds);

          final postsMap = <String, PostModel>{
            for (final json in (repostedPostsData as List))
              (json as Map<String, dynamic>)['id'] as String: PostModel.fromJson(
                json,
                isLiked: likedIds.contains(json['id']),
                isSaved: savedIds.contains(json['id']),
                isReposted: repostedIds.contains(json['id']),
              ),
          };

          for (final r in repostsRaw) {
            final post = postsMap[r['post_id'] as String];
            if (post == null) continue;
            final reposterJson = r['Users'] as Map<String, dynamic>?;
            if (reposterJson == null) continue;
            repostItems.add(FeedItem(
              post: post,
              repostedBy: SocialUserModel.fromJson(reposterJson),
              sortDate: DateTime.parse(r['created_at'] as String),
            ));
          }
        }
      } catch (_) {}
    }

    // Merge: deduplicate (postId + reposterId) then sort by effective date
    final seen = <String>{};
    final all = <FeedItem>[];
    for (final item in [...repostItems, ...postItems]) {
      final key = item.isRepost
          ? '${item.post.id}_${item.repostedBy!.id}'
          : item.post.id;
      if (seen.add(key)) all.add(item);
    }
    all.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return all.take(pageSize).toList();
  }

  Future<List<PostModel>> getUserPosts({
    required String profileUserId,
    required String currentUserId,
    int page = 0,
    int pageSize = 15,
  }) async {
    final likedIds = await _getLikedPostIds(currentUserId);
    final savedIds = await _getSavedPostIds(currentUserId);

    final data = await _supabase
        .from('posts')
        .select(_postSelect)
        .eq('user_id', profileUserId)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((json) {
      final map = json as Map<String, dynamic>;
      return PostModel.fromJson(
        map,
        isLiked: likedIds.contains(map['id']),
        isSaved: savedIds.contains(map['id']),
      );
    }).toList();
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<PostModel> createPost({
    required String userId,
    String? caption,
    String? imageUrl,
  }) async {
    final insertData = <String, dynamic>{'user_id': userId};
    if (caption != null && caption.isNotEmpty) insertData['caption'] = caption;
    if (imageUrl != null) insertData['image_url'] = imageUrl;

    final res = await _supabase
        .from('posts')
        .insert(insertData)
        .select(_postSelect)
        .single();
    return PostModel.fromJson(res);
  }

  Future<void> deletePost(String postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }

  Future<String?> uploadPostImage(
    String userId,
    Uint8List bytes,
    String ext,
  ) async {
    final path = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _supabase.storage.from('UserPosts').uploadBinary(path, bytes);
    return _supabase.storage.from('UserPosts').getPublicUrl(path);
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('post_likes')
        .upsert({'post_id': postId, 'user_id': userId});
  }

  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Future<List<CommentModel>> getComments(String postId) async {
    final data = await _supabase
        .from('post_comments')
        .select('*, Users(id, username, image_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return (data as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String comment,
  }) async {
    final res = await _supabase
        .from('post_comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'comment': comment,
        })
        .select('*, Users(id, username, image_url)')
        .single();
    return CommentModel.fromJson(res);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.from('post_comments').delete().eq('id', commentId);
  }

  // ── Saved posts ───────────────────────────────────────────────────────────

  Future<void> savePost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('saved_posts')
        .upsert({'post_id': postId, 'user_id': userId});
  }

  Future<void> unsavePost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('saved_posts')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  Future<List<PostModel>> getSavedPosts({
    required String userId,
    int page = 0,
    int pageSize = 15,
  }) async {
    final savedIds = await _getSavedPostIds(userId);
    if (savedIds.isEmpty) return [];

    final likedIds = await _getLikedPostIds(userId);
    final repostedIds = await _getRepostedPostIds(userId);

    final data = await _supabase
        .from('posts')
        .select(_postSelect)
        .inFilter('id', savedIds.toList())
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((json) {
      final map = json as Map<String, dynamic>;
      return PostModel.fromJson(
        map,
        isLiked: likedIds.contains(map['id']),
        isSaved: true,
        isReposted: repostedIds.contains(map['id']),
      );
    }).toList();
  }

  // ── Stories ───────────────────────────────────────────────────────────────

  Future<List<StoryModel>> getStories(String userId) async {
    final friendIds = await _getAcceptedFriendIds(userId);
    final visibleIds = [...friendIds, userId];

    final data = await _supabase
        .from('stories')
        .select('*, Users(id, username, image_url)')
        .inFilter('user_id', visibleIds)
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    final Set<String> seenStoryIds = {};
    try {
      final viewsData = await _supabase
          .from('story_views')
          .select('story_id')
          .eq('viewer_id', userId);
      for (final v in (viewsData as List)) {
        seenStoryIds.add(v['story_id'] as String);
      }
    } catch (_) {}

    final stories = (data as List)
        .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final box = Hive.isBoxOpen('seen_stories') ? Hive.box('seen_stories') : null;

    for (final story in stories) {
      final isSeenLocally = box?.get('${userId}_${story.id}', defaultValue: false) as bool? ?? false;
      if (seenStoryIds.contains(story.id) || isSeenLocally) {
        story.isSeen = true;
      }
    }

    return stories;
  }

  Future<void> createStory({
    required String userId,
    required String imageUrl,
  }) async {
    final expiresAt = DateTime.now().add(const Duration(hours: 24));
    await _supabase.from('stories').insert({
      'user_id': userId,
      'image_url': imageUrl,
      'expires_at': expiresAt.toIso8601String(),
    });
  }

  Future<String?> uploadStoryImage(
    String userId,
    Uint8List bytes,
    String ext,
  ) async {
    final path =
        'stories/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _supabase.storage.from('UserPosts').uploadBinary(path, bytes);
    return _supabase.storage.from('UserPosts').getPublicUrl(path);
  }

  Future<void> markStoryViewed(String storyId, String viewerId) async {
    bool written = false;
    try {
      await _supabase.from('story_views').upsert(
        {'story_id': storyId, 'viewer_id': viewerId},
        onConflict: 'story_id,viewer_id',
      );
      written = true;
    } catch (_) {}

    if (!written) {
      try {
        final box = Hive.box('seen_stories');
        await box.put('${viewerId}_$storyId', true);
      } catch (_) {}
    }
  }

  Future<List<({SocialUserModel viewer, bool liked})>> getStoryViewers(
      String storyId) async {
    final viewData = await _supabase
        .from('story_views')
        .select('viewer_id')
        .eq('story_id', storyId)
        .order('viewed_at', ascending: false);
    final ids =
        (viewData as List).map((v) => v['viewer_id'] as String).toList();
    if (ids.isEmpty) return [];

    final likeData = await _supabase
        .from('story_likes')
        .select('user_id')
        .eq('story_id', storyId);
    final likerIds =
        (likeData as List).map((l) => l['user_id'] as String).toSet();

    final users = await _supabase
        .from('Users')
        .select('id, username, image_url')
        .inFilter('id', ids);

    final userMap = {
      for (final e in users as List)
        (e as Map<String, dynamic>)['id'] as String:
            SocialUserModel.fromJson(e)
    };

    return ids
        .where((id) => userMap.containsKey(id))
        .map((id) => (viewer: userMap[id]!, liked: likerIds.contains(id)))
        .toList();
  }

  Future<({int count, bool isLiked})> getStoryLikeInfo(
      String storyId, String userId) async {
    final data = await _supabase
        .from('story_likes')
        .select('user_id')
        .eq('story_id', storyId);
    final likes = data as List;
    return (
      count: likes.length,
      isLiked: likes.any((l) => l['user_id'] == userId),
    );
  }

  Future<void> likeStory(String storyId, String userId) async {
    await _supabase.from('story_likes').upsert(
      {'story_id': storyId, 'user_id': userId},
      onConflict: 'story_id,user_id',
    );
  }

  Future<void> unlikeStory(String storyId, String userId) async {
    await _supabase
        .from('story_likes')
        .delete()
        .eq('story_id', storyId)
        .eq('user_id', userId);
  }

  // ── Friendships ───────────────────────────────────────────────────────────

  Future<void> sendFriendRequest({
    required String requesterId,
    required String addresseeId,
  }) async {
    final friendship = await _supabase.from('friendships').insert({
      'requester_id': requesterId,
      'addressee_id': addresseeId,
      'status': 'pending',
    }).select('id').single();

    final friendshipId = friendship['id'] as String;

    String requesterName = 'Someone';
    try {
      final user = await _supabase
          .from('Users')
          .select('username')
          .eq('id', requesterId)
          .maybeSingle();
      if (user != null) {
        requesterName = user['username'] ?? 'Someone';
      }
    } catch (_) {}

    await _supabase.from('notifications').insert({
      'user_id': addresseeId,
      'title': 'Friend Request Received',
      'message': '$requesterName sent you a friend request.',
      'type': 'friend_request_received:$friendshipId',
      'is_read': false,
    });
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    final friendship = await _supabase
        .from('friendships')
        .select('requester_id, addressee_id')
        .eq('id', friendshipId)
        .single();
    final requesterId = friendship['requester_id'] as String;
    final addresseeId = friendship['addressee_id'] as String;

    await _supabase
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId);

    String addresseeName = 'Someone';
    try {
      final user = await _supabase
          .from('Users')
          .select('username')
          .eq('id', addresseeId)
          .maybeSingle();
      if (user != null) {
        addresseeName = user['username'] ?? 'Someone';
      }
    } catch (_) {}

    await _supabase.from('notifications').insert({
      'user_id': requesterId,
      'title': 'Friend Request Accepted',
      'message': '$addresseeName accepted your friend request.',
      'type': 'friend_request_accepted',
      'is_read': false,
    });
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _supabase
        .from('friendships')
        .update({'status': 'rejected'})
        .eq('id', friendshipId);
  }

  Future<void> removeFriend(String friendshipId) async {
    await _supabase.from('friendships').delete().eq('id', friendshipId);
  }

  Future<List<FriendshipModel>> getPendingRequests(String userId) async {
    final data = await _supabase
        .from('friendships')
        .select(
          'id, requester_id, addressee_id, status, created_at, '
          'requester:requester_id(id, username, image_url)',
        )
        .eq('addressee_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map(
          (e) => FriendshipModel.fromJson(
            e as Map<String, dynamic>,
            currentUserId: userId,
          ),
        )
        .toList();
  }

  Future<List<FriendshipModel>> getFriends(String userId) async {
    final asRequester = await _supabase
        .from('friendships')
        .select(
          'id, requester_id, addressee_id, status, created_at, '
          'addressee:addressee_id(id, username, image_url)',
        )
        .eq('requester_id', userId)
        .eq('status', 'accepted');

    final asAddressee = await _supabase
        .from('friendships')
        .select(
          'id, requester_id, addressee_id, status, created_at, '
          'requester:requester_id(id, username, image_url)',
        )
        .eq('addressee_id', userId)
        .eq('status', 'accepted');

    return [
      ...(asRequester as List).map(
        (e) => FriendshipModel.fromJson(
          e as Map<String, dynamic>,
          currentUserId: userId,
        ),
      ),
      ...(asAddressee as List).map(
        (e) => FriendshipModel.fromJson(
          e as Map<String, dynamic>,
          currentUserId: userId,
        ),
      ),
    ];
  }

  Future<FriendshipStatus> checkFriendship(
    String currentUserId,
    String otherUserId,
  ) async {
    final data = await _supabase
        .from('friendships')
        .select('status')
        .or(
          'and(requester_id.eq.$currentUserId,addressee_id.eq.$otherUserId),'
          'and(requester_id.eq.$otherUserId,addressee_id.eq.$currentUserId)',
        )
        .maybeSingle();

    if (data == null) return FriendshipStatus.none;
    return switch (data['status'] as String) {
      'accepted' => FriendshipStatus.accepted,
      'rejected' => FriendshipStatus.rejected,
      _ => FriendshipStatus.pending,
    };
  }

  Future<String?> getFriendshipId(
    String currentUserId,
    String otherUserId,
  ) async {
    final data = await _supabase
        .from('friendships')
        .select('id')
        .or(
          'and(requester_id.eq.$currentUserId,addressee_id.eq.$otherUserId),'
          'and(requester_id.eq.$otherUserId,addressee_id.eq.$currentUserId)',
        )
        .maybeSingle();
    return data?['id'] as String?;
  }

  // ── Workout access (respects workouts.visibility) ─────────────────────────

  Future<List<Map<String, dynamic>>> getFriendWorkouts({
    required String profileUserId,
    required String currentUserId,
  }) async {
    final status = await checkFriendship(currentUserId, profileUserId);
    final areFriends = status == FriendshipStatus.accepted;

    if (!areFriends) {
      final data = await _supabase
          .from('workouts')
          .select('id, name, date, duration_seconds, visibility')
          .eq('user_id', profileUserId)
          .eq('visibility', 'public')
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    }

    final data = await _supabase
        .from('workouts')
        .select('id, name, date, duration_seconds, visibility')
        .eq('user_id', profileUserId)
        .neq('visibility', 'private')
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // ── User search ───────────────────────────────────────────────────────────

  Future<SocialUserModel?> findUserByEmail({
    required String email,
    required String currentUserId,
  }) async {
    final data = await _supabase
        .from('Users')
        .select('id, username, image_url')
        .eq('email', email.trim().toLowerCase())
        .neq('id', currentUserId)
        .maybeSingle();
    if (data == null) return null;
    return SocialUserModel.fromJson(data);
  }

  Future<List<SocialUserModel>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    final data = await _supabase
        .from('Users')
        .select('id, username, image_url')
        .ilike('username', '%$query%')
        .neq('id', currentUserId)
        .limit(30);
    return (data as List)
        .map((e) => SocialUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SocialUserModel> getUserProfile(String userId) async {
    final data = await _supabase
        .from('Users')
        .select('id, username, image_url')
        .eq('id', userId)
        .single();
    return SocialUserModel.fromJson(data);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<List<String>> _getAcceptedFriendIds(String userId) async {
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

    return [
      ...(asRequester as List).map((e) => e['addressee_id'] as String),
      ...(asAddressee as List).map((e) => e['requester_id'] as String),
    ];
  }

  Future<Set<String>> _getLikedPostIds(String userId) async {
    final data = await _supabase
        .from('post_likes')
        .select('post_id')
        .eq('user_id', userId);
    return {for (final e in data as List) e['post_id'] as String};
  }

  Future<Set<String>> _getSavedPostIds(String userId) async {
    final data = await _supabase
        .from('saved_posts')
        .select('post_id')
        .eq('user_id', userId);
    return {for (final e in data as List) e['post_id'] as String};
  }

  Future<Set<String>> _getRepostedPostIds(String userId) async {
    final data = await _supabase
        .from('post_reposts')
        .select('post_id')
        .eq('user_id', userId);
    return {for (final e in data as List) e['post_id'] as String};
  }

  // ── Reposts ───────────────────────────────────────────────────────────────

  Future<void> repostPost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('post_reposts')
        .upsert({'post_id': postId, 'user_id': userId});
  }

  Future<void> unrepostPost({
    required String postId,
    required String userId,
  }) async {
    await _supabase
        .from('post_reposts')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }
}
