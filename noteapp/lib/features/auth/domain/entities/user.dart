class User {
  final String username;
  String? lastSynced; // timestamp, nullable

  User({required this.username, this.lastSynced});
}
