import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';


class CreateCommentUseCase {
  final CommentRepository _commentRepository;

  CreateCommentUseCase(this._commentRepository);

  /// 댓글 생성
  Future<Result<Comment>> call({
    required String postId,
    required String userId,
    required String content,
  }) {
    return _commentRepository.createComment(
      postId: postId,
      userId: userId,
      content: content,
    );
  }
}

