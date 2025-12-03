import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_post_by_id_usecase.dart';

class DeletePostUseCase {
  final PostRepository _postRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetPostByIdUseCase _getPostByIdUseCase;

  DeletePostUseCase(
    this._postRepository,
    this._getCurrentUserUseCase,
    this._getPostByIdUseCase,
  );

  /// 게시글 삭제
  Future<Result<void>> call(String id) async {
    // 1. 필수값 검증
    if (id.trim().isEmpty) {
      return const Failure('게시글 ID가 필요합니다');
    }

    // 2. 로그인 상태 확인
    final userId = _getCurrentUserUseCase.getCurrentUserId();
    if (userId == null) {
      return const Failure('로그인이 필요합니다');
    }

    // 3. 게시글 존재 확인 및 권한 확인
    final getPostResult = await _getPostByIdUseCase(id);
    final post = getPostResult.when(
      success: (p) => p,
      failure: (message, _) => null,
    );

    if (post == null) {
      return const Failure('게시글을 찾을 수 없습니다');
    }

    // 4. 작성자 권한 확인
    if (post.authorId != userId) {
      return const Failure('삭제 권한이 없습니다');
    }

    // 5. Repository 호출
    return _postRepository.deletePost(id);
  }
}

