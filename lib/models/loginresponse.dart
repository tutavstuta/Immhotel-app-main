class LoginResponse {
  final String token;
  final String message;
  final String tokenType;

  const LoginResponse({
    required this.token,
    required this.message,
    required this.tokenType,

  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'token': String token,
        'message': String message,
        'tokenType': String tokenType,

      } =>
        LoginResponse(
          token: token,
          message: message,
          tokenType: tokenType,

        ),
      _ => throw const FormatException('Failed to login'),
    };
  }
}
