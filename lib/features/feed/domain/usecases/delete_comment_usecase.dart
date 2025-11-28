import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';


class DeleteCommentUseCase {
  final CommentRepository _commentRepository;

  DeleteCommentUseCase(this._commentRepository);

  /// 댓글 삭제
  Future<Result<void>> call(String commentId) {
    return _commentRepository.deleteComment(commentId);
  }
}

