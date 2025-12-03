import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_comments_usecase.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';

class DeleteCommentUseCase {
  final CommentRepository _commentRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetCommentsUseCase _getCommentsUseCase;

  DeleteCommentUseCase(
    this._commentRepository,
    this._getCurrentUserUseCase,
    this._getCommentsUseCase,
  );

  /// 댓글 삭제
  Future<Result<void>> call(String commentId, String? postId) async {
    // 1. 필수값 검증
    if (commentId.trim().isEmpty) {
      return const Failure('댓글 ID가 필요합니다');
    }

    // 2. 로그인 상태 확인
    final userId = _getCurrentUserUseCase.getCurrentUserId();
    if (userId == null) {
      return const Failure('로그인이 필요합니다');
    }

    // 3. 권한 확인 (postId가 제공된 경우에만)
    if (postId != null && postId.trim().isNotEmpty) {
      final commentsResult = await _getCommentsUseCase(postId);
      final comments = commentsResult.when(
        success: (comments) => comments,
        failure: (_, __) => <Comment>[],
      );

      final comment = comments.where((c) => c.id == commentId).firstOrNull;

      if (comment == null) {
        return const Failure('댓글을 찾을 수 없습니다');
      }

      // 4. 작성자 권한 확인
      if (comment.userId != userId) {
        return const Failure('삭제 권한이 없습니다');
      }
    }

    // 5. Repository 호출
    return _commentRepository.deleteComment(commentId);
  }
}

