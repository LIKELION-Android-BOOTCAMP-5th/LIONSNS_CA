/// 순수한 비즈니스 객체로, 외부 의존성 없음
class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? imageUrl;
  final String? thumbnailUrl; // 리스트 표시용 썸네일 URL
  final DateTime createdAt;
  final DateTime updatedAt;

  // 조인된 데이터 (선택적)
  final String? authorName;
  final String? authorImageUrl;
  final int? likesCount;
  final int? commentsCount;
  final bool? isLiked;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.imageUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorImageUrl,
    this.likesCount,
    this.commentsCount,
    this.isLiked,
  });

  /// 생성용 팩토리 (ID와 날짜를 자동 생성)
  factory Post.create({
    required String title,
    required String content,
    required String authorId,
    String? imageUrl,
    String? thumbnailUrl,
  }) {
    final now = DateTime.now();
    return Post(
      id: '', // 서버에서 생성
      title: title,
      content: content,
      authorId: authorId,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 업데이트용 copyWith
  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorImageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// author 필드 (하위 호환성)
  String get author => authorName ?? '익명';
}

