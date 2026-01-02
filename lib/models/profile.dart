import 'package:meta/meta.dart';

@immutable
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.consistencyScore,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String email;
  final double consistencyScore;
  final String? avatarUrl;

  Profile copyWith({
    String? displayName,
    String? email,
    double? consistencyScore,
    String? avatarUrl,
  }) {
    return Profile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    final score = map['consistency_score'];
    return Profile(
      id: map['id'] as String? ?? '',
      displayName: map['display_name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      consistencyScore: score is num ? score.toDouble() : 0,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
