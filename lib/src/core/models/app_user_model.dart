import 'package:equatable/equatable.dart';

/// The (locally authenticated) current user. There is no backend in this
/// project — see [AuthRepository] — so this only ever lives in
/// [LocalStorageService].
class AppUser extends Equatable {
  const AppUser({
    required this.email,
    required this.fullName,
    required this.joinedAt,
  });

  final String email;
  final String fullName;
  final DateTime joinedAt;

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [email, fullName, joinedAt];
}
