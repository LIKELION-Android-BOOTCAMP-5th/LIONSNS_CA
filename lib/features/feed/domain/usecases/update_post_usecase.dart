import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_post_by_id_usecase.dart';

class UpdatePostUseCase {
  final PostRepository _postRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetPostByIdUseCase _getPostByIdUseCase;

  UpdatePostUseCase(
    this._postRepository,
    this._getCurrentUserUseCase,
    this._getPostByIdUseCase,
  );

  /// 게시글 업데이트
  Future<Result<Post>> call(Post post) async {
    // 1. 필수값 검증
    if (post.title.trim().isEmpty) {
      return const Failure('제목을 입력해주세요');
    }
    if (post.content.trim().isEmpty) {
      return const Failure('내용을 입력해주세요');
    }

    // 2. 제목 길이 제한 검증
    if (post.title.length > 100) {
      return const Failure('제목은 100자 이하여야 합니다');
    }

    // 3. 내용 길이 제한 검증
    if (post.content.length > 5000) {
      return const Failure('내용은 5000자 이하여야 합니다');
    }

    // 4. 로그인 상태 확인
    final userId = _getCurrentUserUseCase.getCurrentUserId();
    if (userId == null) {
      return const Failure('로그인이 필요합니다');
    }

    // 5. 게시글 존재 확인 및 권한 확인
    final getPostResult = await _getPostByIdUseCase(post.id);
    final existingPost = getPostResult.when(
      success: (p) => p,
      failure: (message, _) => null,
    );

    if (existingPost == null) {
      return const Failure('게시글을 찾을 수 없습니다');
    }

    // 6. 작성자 권한 확인
    if (existingPost.authorId != userId) {
      return const Failure('수정 권한이 없습니다');
    }

    // 7. Repository 호출
    return _postRepository.updatePost(post);
  }
}

