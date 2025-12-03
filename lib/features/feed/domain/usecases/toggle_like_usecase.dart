import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';

class ToggleLikeUseCase {
  final LikeRepository _likeRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  ToggleLikeUseCase(
    this._likeRepository,
    this._getCurrentUserUseCase,
  );

  /// 좋아요 토글 (추가/제거)
  Future<Result<bool>> call(String postId, String? userId) async {
    // 1. 필수값 검증
    if (postId.trim().isEmpty) {
      return const Failure('게시글 ID가 필요합니다');
    }

    // 2. 로그인 상태 확인
    final currentUserId = userId ?? _getCurrentUserUseCase.getCurrentUserId();
    if (currentUserId == null) {
      return const Failure('로그인이 필요합니다');
    }

    // 3. Repository 호출
    return _likeRepository.toggleLike(postId, currentUserId);
  }
}

