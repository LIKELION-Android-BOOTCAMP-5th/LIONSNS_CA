import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_post_datasource.dart';

class SupabasePostRepository implements PostRepository {
  final SupabasePostDatasource _postDatasource;

  SupabasePostRepository(this._postDatasource);

  @override
  Future<Result<List<Post>>> getPosts() async {
    return await _postDatasource.getPosts();
  }

  @override
  Future<Result<Post>> getPostById(String id) async {
    return await _postDatasource.getPostById(id);
  }

  @override
  Future<Result<Post>> createPost(Post post) async {
    return await _postDatasource.createPost(post);
  }

  @override
  Future<Result<Post>> updatePost(Post post) async {
    return await _postDatasource.updatePost(post);
  }

  @override
  Future<Result<void>> deletePost(String id) async {
    return await _postDatasource.deletePost(id);
  }

  @override
  Future<Result<Map<String, dynamic>>> getPostStats() async {
    return await _postDatasource.getPostStats();
  }

  @override
  Future<Result<List<Post>>> getUserLikedPosts(String userId) async {
    return await _postDatasource.getUserLikedPosts(userId);
  }
}

