import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository _postRepository;

  CreatePostUseCase(this._postRepository);

  /// 게시글 생성
  Future<Result<Post>> call(Post post) {
    return _postRepository.createPost(post);
  }
}

