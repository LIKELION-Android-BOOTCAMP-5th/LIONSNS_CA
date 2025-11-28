import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/usecases/get_posts_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/delete_post_usecase.dart';

class PostListViewModel extends StateNotifier<Result<List<Post>>> {
  final GetPostsUseCase _getPostsUseCase;
  final DeletePostUseCase _deletePostUseCase;

  PostListViewModel({
    required GetPostsUseCase getPostsUseCase,
    required DeletePostUseCase deletePostUseCase,
  })  : _getPostsUseCase = getPostsUseCase,
        _deletePostUseCase = deletePostUseCase,
        super(const Pending<List<Post>>());

  /// 게시글 목록 로드
  Future<void> loadPosts() async {
    state = const Pending<List<Post>>();
    final result = await _getPostsUseCase();
    state = result;
  }

  /// 게시글 삭제 및 목록 새로고침
  Future<void> deletePost(String id) async {
    final result = await _deletePostUseCase(id);
    if (result is Success) {
      // 삭제 성공 시 목록을 새로고침하여 UI 동기화
      await loadPosts();
    }
  }
}

