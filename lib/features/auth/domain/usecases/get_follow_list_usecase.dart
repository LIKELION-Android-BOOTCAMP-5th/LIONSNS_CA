import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';


class GetFollowListUseCase {
  final FollowRepository _followRepository;

  GetFollowListUseCase(this._followRepository);

  /// 팔로워 목록 조회
  Future<Result<List<User>>> getFollowers(String userId) {
    return _followRepository.getFollowers(userId);
  }

  /// 팔로잉 목록 조회
  Future<Result<List<User>>> getFollowing(String userId) {
    return _followRepository.getFollowing(userId);
  }
}

