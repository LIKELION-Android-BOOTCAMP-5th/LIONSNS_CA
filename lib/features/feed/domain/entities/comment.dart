/// 순수한 비즈니스 객체로, 외부 의존성 없음
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 조인된 데이터 (선택적)
  final String? authorName;
  final String? authorImageUrl;
  final String? postTitle;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorImageUrl,
    this.postTitle,
  });

  /// 생성용 팩토리
  factory Comment.create({
    required String postId,
    required String userId,
    required String content,
  }) {
    final now = DateTime.now();
    return Comment(
      id: '', // 서버에서 생성
      postId: postId,
      userId: userId,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 업데이트용 copyWith
  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorImageUrl,
    String? postTitle,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      postTitle: postTitle ?? this.postTitle,
    );
  }
}



