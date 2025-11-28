import 'package:json_annotation/json_annotation.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';

part 'post_dto.g.dart';

/// Post Data Transfer Object
/// 외부 데이터 소스(Supabase, API 등)와의 통신에 사용
@JsonSerializable()
class PostDto {
  final String id;
  final String title;
  final String content;
  @JsonKey(name: 'user_id')
  final String authorId;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  // 조인된 데이터 (선택적)
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'author_image_url')
  final String? authorImageUrl;
  @JsonKey(name: 'likes_count')
  final int? likesCount;
  @JsonKey(name: 'comments_count')
  final int? commentsCount;
  @JsonKey(name: 'is_liked')
  final bool? isLiked;

  const PostDto({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorImageUrl,
    this.likesCount,
    this.commentsCount,
    this.isLiked,
  });

  /// JSON에서 객체로 변환
  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$PostDtoToJson(this);

  /// Domain Entity로 변환
  Post toEntity() {
    return Post(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      imageUrl: imageUrl,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      authorName: authorName,
      authorImageUrl: authorImageUrl,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked,
    );
  }

  /// Domain Entity에서 DTO 생성
  factory PostDto.fromEntity(Post post) {
    return PostDto(
      id: post.id,
      title: post.title,
      content: post.content,
      authorId: post.authorId,
      imageUrl: post.imageUrl,
      createdAt: post.createdAt.toIso8601String(),
      updatedAt: post.updatedAt.toIso8601String(),
      authorName: post.authorName,
      authorImageUrl: post.authorImageUrl,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      isLiked: post.isLiked,
    );
  }
}

