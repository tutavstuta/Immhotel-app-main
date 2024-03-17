class User {
  final String userId;
  final String email;
  final String name;
  final String telephone;

  const User({
    required this.userId,
    required this.email,
    required this.name,
    required this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userId': String userId,
        'email': String email,
        'name': String name,
        'telephone': String telephone,
      } =>
        User(
          userId: userId,
          email: email,
          name: name,
          telephone: telephone,
        ),
      _ => throw const FormatException('Failed to get user'),
    };
  }
}
