class UserProfile {
  final String pubkey;
  final String? displayName;
  final String? pictureUrl;

  UserProfile({
    required this.pubkey,
    this.displayName,
    this.pictureUrl,
  });
}
