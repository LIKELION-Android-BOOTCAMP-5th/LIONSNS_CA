import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';


class ToggleFollowUseCase {
  final FollowRepository _followRepository;

  ToggleFollowUseCase(this._followRepository);

  /// 팔로우 토글 실행
  Future<Result<bool>> call(String followerId, String followingId) {
    return _followRepository.toggleFollow(followerId, followingId);
  }
}

