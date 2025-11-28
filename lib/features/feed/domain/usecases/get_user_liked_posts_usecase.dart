import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';


class GetUserLikedPostsUseCase {
  final PostRepository _postRepository;

  GetUserLikedPostsUseCase(this._postRepository);

  /// 사용자가 좋아요한 게시글 목록 조회
  Future<Result<List<Post>>> call(String userId) {
    return _postRepository.getUserLikedPosts(userId);
  }
}

