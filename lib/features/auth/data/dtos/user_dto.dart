import 'package:json_annotation/json_annotation.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';

part 'user_dto.g.dart';

/// User Data Transfer Object
/// 외부 데이터 소스(Supabase, API 등)와의 통신에 사용
@JsonSerializable()
class UserDto {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String provider;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.provider,
    required this.createdAt,
  });

  /// JSON에서 객체로 변환
  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// Domain Entity로 변환
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      provider: _parseProvider(provider),
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Domain Entity에서 DTO 생성
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      email: user.email,
      profileImageUrl: user.profileImageUrl,
      provider: _providerToString(user.provider),
      createdAt: user.createdAt.toIso8601String(),
    );
  }

  static AuthProvider _parseProvider(String provider) {
    switch (provider) {
      case 'google':
        return AuthProvider.google;
      case 'apple':
        return AuthProvider.apple;
      case 'kakao':
        return AuthProvider.kakao;
      case 'naver':
        return AuthProvider.naver;
      default:
        return AuthProvider.google;
    }
  }

  static String _providerToString(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'google';
      case AuthProvider.apple:
        return 'apple';
      case AuthProvider.kakao:
        return 'kakao';
      case AuthProvider.naver:
        return 'naver';
    }
  }
}

