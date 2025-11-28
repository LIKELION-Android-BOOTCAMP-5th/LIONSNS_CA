import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';


class UpdatePostUseCase {
  final PostRepository _postRepository;

  UpdatePostUseCase(this._postRepository);

  /// 게시글 업데이트
  Future<Result<Post>> call(Post post) {
    return _postRepository.updatePost(post);
  }
}

