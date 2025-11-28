import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';


class GetLikeCountUseCase {
  final LikeRepository _likeRepository;

  GetLikeCountUseCase(this._likeRepository);

  /// 게시글 좋아요 수 조회
  Future<Result<int>> call(String postId) {
    return _likeRepository.getLikeCount(postId);
  }
}

