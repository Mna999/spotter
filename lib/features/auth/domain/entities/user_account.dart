class UserAccount {
  String uid;
  String email;
  String displayName;
  DateTime createdAt;

  UserAccount({
    required this.createdAt,
    required this.displayName,
    required this.email,
    required this.uid,
  });
}
