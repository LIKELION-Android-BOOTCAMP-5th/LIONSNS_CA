import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';


class ToggleLikeUseCase {
  final LikeRepository _likeRepository;

  ToggleLikeUseCase(this._likeRepository);

  /// 좋아요 토글 (추가/제거)
  Future<Result<bool>> call(String postId, String userId) {
    return _likeRepository.toggleLike(postId, userId);
  }
}

