import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_follow_datasource.dart';


class SupabaseFollowRepository implements FollowRepository {
  final SupabaseFollowDatasource _datasource;

  SupabaseFollowRepository(this._datasource);

  @override
  Future<Result<bool>> isFollowing(String followerId, String followingId) {
    return _datasource.isFollowing(followerId, followingId);
  }

  @override
  Future<Result<bool>> toggleFollow(String followerId, String followingId) {
    return _datasource.toggleFollow(followerId, followingId);
  }

  @override
  Future<Result<int>> getFollowerCount(String userId) {
    return _datasource.getFollowerCount(userId);
  }

  @override
  Future<Result<int>> getFollowingCount(String userId) {
    return _datasource.getFollowingCount(userId);
  }

  @override
  Future<Result<List<User>>> getFollowers(String userId) {
    return _datasource.getFollowers(userId);
  }

  @override
  Future<Result<List<User>>> getFollowing(String userId) {
    return _datasource.getFollowing(userId);
  }
}

