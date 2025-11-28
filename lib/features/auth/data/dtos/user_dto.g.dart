// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  profileImageUrl: json['profile_image_url'] as String?,
  provider: json['provider'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'profile_image_url': instance.profileImageUrl,
  'provider': instance.provider,
  'created_at': instance.createdAt,
};
