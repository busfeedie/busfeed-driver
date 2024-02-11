class User {
  final String id;
  final String email;
  final String appId;
  String authorization;

  User(
      {required this.id,
      required this.email,
      required this.appId,
      required this.authorization});
}
