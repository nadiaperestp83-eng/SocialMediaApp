enum FriendshipStatus {
  none,
  pendingSent,
  pendingReceived,
  friends,
}

class FriendshipEntity {
  final String userId;
  final FriendshipStatus status;

  const FriendshipEntity({
    required this.userId,
    required this.status,
  });
}
