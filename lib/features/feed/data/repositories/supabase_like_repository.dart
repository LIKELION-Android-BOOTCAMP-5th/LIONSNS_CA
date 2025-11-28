import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_like_datasource.dart';


class SupabaseLikeRepository implements LikeRepository {
  final SupabaseLikeDatasource _likeDatasource;

  SupabaseLikeRepository(this._likeDatasource);

  @override
  Future<Result<int>> getLikeCount(String postId) async {
    return await _likeDatasource.getLikeCount(postId);
  }

  @override
  Future<Result<bool>> isLiked(String postId, String userId) async {
    return await _likeDatasource.isLiked(postId, userId);
  }

  @override
  Future<Result<void>> addLike(String postId, String userId) async {
    return await _likeDatasource.addLike(postId, userId);
  }

  @override
  Future<Result<void>> removeLike(String postId, String userId) async {
    return await _likeDatasource.removeLike(postId, userId);
  }

  @override
  Future<Result<bool>> toggleLike(String postId, String userId) async {
    return await _likeDatasource.toggleLike(postId, userId);
  }
}

