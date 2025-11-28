import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';

abstract class CommentRepository {
  /// 게시글의 댓글 목록 가져오기
  Future<Result<List<Comment>>> getCommentsByPostId(String postId);

  /// 댓글 생성
  Future<Result<Comment>> createComment({
    required String postId,
    required String userId,
    required String content,
  });

  /// 댓글 업데이트
  Future<Result<Comment>> updateComment({
    required String commentId,
    required String content,
  });

  /// 댓글 삭제
  Future<Result<void>> deleteComment(String commentId);
}

