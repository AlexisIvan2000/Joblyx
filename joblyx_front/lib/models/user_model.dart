class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      profilePicture: data['profile_picture'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}