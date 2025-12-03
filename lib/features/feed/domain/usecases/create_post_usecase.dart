import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';

class CreatePostUseCase {
  final PostRepository _postRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  CreatePostUseCase(
    this._postRepository,
    this._getCurrentUserUseCase,
  );

  /// 게시글 생성
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

    // 5. 작성자 ID 일치 확인
    if (post.authorId != userId) {
      return const Failure('권한이 없습니다');
    }

    // 6. Repository 호출
    return _postRepository.createPost(post);
  }
}

