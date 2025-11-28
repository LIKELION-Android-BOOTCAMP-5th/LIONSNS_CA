import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';


class GetCommentsUseCase {
  final CommentRepository _commentRepository;

  GetCommentsUseCase(this._commentRepository);

  /// 게시글의 댓글 목록 조회
  Future<Result<List<Comment>>> call(String postId) {
    return _commentRepository.getCommentsByPostId(postId);
  }
}

