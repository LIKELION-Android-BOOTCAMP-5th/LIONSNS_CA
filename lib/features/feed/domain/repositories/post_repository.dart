import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';

abstract class PostRepository {
  /// 모든 게시글 가져오기
  Future<Result<List<Post>>> getPosts();

  /// 게시글 ID로 가져오기
  Future<Result<Post>> getPostById(String id);

  /// 게시글 생성
  Future<Result<Post>> createPost(Post post);

  /// 게시글 업데이트
  Future<Result<Post>> updatePost(Post post);

  /// 게시글 삭제
  Future<Result<void>> deletePost(String id);

  /// 게시글 통계 조회
  Future<Result<Map<String, dynamic>>> getPostStats();

  /// 사용자가 좋아요한 게시글 목록 가져오기
  Future<Result<List<Post>>> getUserLikedPosts(String userId);
}

