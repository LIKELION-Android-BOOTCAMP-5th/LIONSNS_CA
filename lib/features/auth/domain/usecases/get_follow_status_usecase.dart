import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';


class GetFollowStatusUseCase {
  final FollowRepository _followRepository;

  GetFollowStatusUseCase(this._followRepository);

  /// 팔로우 상태 확인
  Future<Result<bool>> isFollowing(String followerId, String followingId) {
    return _followRepository.isFollowing(followerId, followingId);
  }

  /// 팔로워 수 조회
  Future<Result<int>> getFollowerCount(String userId) {
    return _followRepository.getFollowerCount(userId);
  }

  /// 팔로잉 수 조회
  Future<Result<int>> getFollowingCount(String userId) {
    return _followRepository.getFollowingCount(userId);
  }
}

