import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';


class GetPostByIdUseCase {
  final PostRepository _postRepository;

  GetPostByIdUseCase(this._postRepository);

  /// 게시글 조회
  Future<Result<Post>> call(String id) {
    return _postRepository.getPostById(id);
  }
}

