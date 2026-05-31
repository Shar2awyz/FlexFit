import 'social_user_model.dart';

enum FriendshipStatus { pending, accepted, rejected, none }

class FriendshipModel {
  final String id;
  final String requesterId;
  final String addresseeId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final SocialUserModel? otherUser;

  const FriendshipModel({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    this.otherUser,
  });

  factory FriendshipModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = switch (statusStr) {
      'accepted' => FriendshipStatus.accepted,
      'rejected' => FriendshipStatus.rejected,
      _ => FriendshipStatus.pending,
    };

    final requesterId = json['requester_id'] as String;
    final addresseeId = json['addressee_id'] as String;

    Map<String, dynamic>? otherUserJson;
    if (currentUserId != null) {
      if (requesterId == currentUserId) {
        otherUserJson = json['addressee'] as Map<String, dynamic>?;
      } else {
        otherUserJson = json['requester'] as Map<String, dynamic>?;
      }
    }

    return FriendshipModel(
      id: json['id'] as String,
      requesterId: requesterId,
      addresseeId: addresseeId,
      status: status,
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUser:
          otherUserJson != null ? SocialUserModel.fromJson(otherUserJson) : null,
    );
  }
}
