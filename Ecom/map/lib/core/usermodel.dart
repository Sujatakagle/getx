class SignInResponse {
  final String message;
  final String userId;
  final String username;
  final String email;
  final String phoneNumber;

  SignInResponse({
    required this.message,
    required this.userId,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  // Factory constructor to create an instance from JSON
  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      message: json['message'],
      userId: json['user']['id'],
      username: json['user']['username'],
      email: json['user']['email'],
      phoneNumber: json['user']['phoneNumber'],
    );
  }

  // Method to convert the object back to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': {
        'id': userId,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
      }
    };
  }
}
