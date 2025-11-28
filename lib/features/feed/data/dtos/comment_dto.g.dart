// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentDto _$CommentDtoFromJson(Map<String, dynamic> json) => CommentDto(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  userId: json['user_id'] as String,
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  authorName: json['author_name'] as String?,
  authorImageUrl: json['author_image_url'] as String?,
);

Map<String, dynamic> _$CommentDtoToJson(CommentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'content': instance.content,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'author_name': instance.authorName,
      'author_image_url': instance.authorImageUrl,
    };
