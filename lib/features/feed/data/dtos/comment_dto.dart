import 'package:json_annotation/json_annotation.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';

part 'comment_dto.g.dart';

/// Comment Data Transfer Object
/// 외부 데이터 소스(Supabase, API 등)와의 통신에 사용
@JsonSerializable()
class CommentDto {
  final String id;
  @JsonKey(name: 'post_id')
  final String postId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  // 조인된 데이터 (선택적)
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'author_image_url')
  final String? authorImageUrl;

  const CommentDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorImageUrl,
  });

  /// JSON에서 객체로 변환
  factory CommentDto.fromJson(Map<String, dynamic> json) => _$CommentDtoFromJson(json);

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);

  /// Domain Entity로 변환
  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      authorName: authorName,
      authorImageUrl: authorImageUrl,
    );
  }

  /// Domain Entity에서 DTO 생성
  factory CommentDto.fromEntity(Comment comment) {
    return CommentDto(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      content: comment.content,
      createdAt: comment.createdAt.toIso8601String(),
      updatedAt: comment.updatedAt.toIso8601String(),
      authorName: comment.authorName,
      authorImageUrl: comment.authorImageUrl,
    );
  }
}

