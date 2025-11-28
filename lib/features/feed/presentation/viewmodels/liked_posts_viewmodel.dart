import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/usecases/get_user_liked_posts_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';

class LikedPostsViewModel extends StateNotifier<Result<List<Post>>> {
  final GetUserLikedPostsUseCase _getUserLikedPostsUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  LikedPostsViewModel({
    required GetUserLikedPostsUseCase getUserLikedPostsUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _getUserLikedPostsUseCase = getUserLikedPostsUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const Pending<List<Post>>());

  /// 좋아요한 게시글 목록 로드
  Future<void> loadLikedPosts() async {
    final currentUserId = _getCurrentUserUseCase.getCurrentUserId();
    if (currentUserId == null) {
      state = Failure<List<Post>>('로그인이 필요합니다');
      return;
    }

    state = const Pending<List<Post>>();
    final result = await _getUserLikedPostsUseCase(currentUserId);
    state = result;
  }
}

