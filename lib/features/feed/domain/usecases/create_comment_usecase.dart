import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';

class CreateCommentUseCase {
  final CommentRepository _commentRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  CreateCommentUseCase(
    this._commentRepository,
    this._getCurrentUserUseCase,
  );

  /// 댓글 생성
  Future<Result<Comment>> call({
    required String postId,
    required String? userId,
    required String content,
  }) async {
    // 1. 필수값 검증
    if (postId.trim().isEmpty) {
      return const Failure('게시글 ID가 필요합니다');
    }
    if (content.trim().isEmpty) {
      return const Failure('댓글 내용을 입력해주세요');
    }

    // 2. 댓글 길이 제한 검증
    if (content.length > 1000) {
      return const Failure('댓글은 1000자 이하여야 합니다');
    }

    // 3. 로그인 상태 확인
    final currentUserId = userId ?? _getCurrentUserUseCase.getCurrentUserId();
    if (currentUserId == null) {
      return const Failure('로그인이 필요합니다');
    }

    // 4. Repository 호출
    return _commentRepository.createComment(
      postId: postId,
      userId: currentUserId,
      content: content,
    );
  }
}

