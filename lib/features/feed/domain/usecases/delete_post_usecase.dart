import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';


class DeletePostUseCase {
  final PostRepository _postRepository;

  DeletePostUseCase(this._postRepository);

  /// 게시글 삭제
  Future<Result<void>> call(String id) {
    return _postRepository.deletePost(id);
  }
}

