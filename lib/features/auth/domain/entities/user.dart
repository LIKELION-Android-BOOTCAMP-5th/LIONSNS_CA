/// 순수한 비즈니스 객체로, 외부 의존성 없음
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final AuthProvider provider;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.provider,
    required this.createdAt,
  });

  /// copyWith 메서드
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    AuthProvider? provider,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 인증 제공자
enum AuthProvider {
  google,
  apple,
  kakao,
  naver,
}