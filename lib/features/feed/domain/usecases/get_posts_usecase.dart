import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository _postRepository;

  GetPostsUseCase(this._postRepository);

  /// 게시글 목록 조회
  Future<Result<List<Post>>> call() {
    return _postRepository.getPosts();
  }
}

