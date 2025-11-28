// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  authorId: json['user_id'] as String,
  imageUrl: json['image_url'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  authorName: json['author_name'] as String?,
  authorImageUrl: json['author_image_url'] as String?,
  likesCount: (json['likes_count'] as num?)?.toInt(),
  commentsCount: (json['comments_count'] as num?)?.toInt(),
  isLiked: json['is_liked'] as bool?,
);

Map<String, dynamic> _$PostDtoToJson(PostDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'user_id': instance.authorId,
  'image_url': instance.imageUrl,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'author_name': instance.authorName,
  'author_image_url': instance.authorImageUrl,
  'likes_count': instance.likesCount,
  'comments_count': instance.commentsCount,
  'is_liked': instance.isLiked,
};
