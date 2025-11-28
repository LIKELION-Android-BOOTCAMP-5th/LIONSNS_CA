import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';

abstract class FollowRepository {
  /// 팔로우 상태 확인
  Future<Result<bool>> isFollowing(String followerId, String followingId);

  /// 팔로우 토글
  Future<Result<bool>> toggleFollow(String followerId, String followingId);

  /// 팔로워 수 조회
  Future<Result<int>> getFollowerCount(String userId);

  /// 팔로잉 수 조회
  Future<Result<int>> getFollowingCount(String userId);

  /// 팔로워 목록 조회
  Future<Result<List<User>>> getFollowers(String userId);

  /// 팔로잉 목록 조회
  Future<Result<List<User>>> getFollowing(String userId);
}

