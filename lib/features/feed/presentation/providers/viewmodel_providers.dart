import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/providers/usecase_providers.dart' as auth_providers;
import '../viewmodels/post_list_viewmodel.dart';
import '../viewmodels/post_form_viewmodel.dart';
import '../viewmodels/post_detail_viewmodel.dart';
import '../viewmodels/liked_posts_viewmodel.dart';
import '../../domain/providers/usecase_providers.dart';

final postListViewModelProvider = StateNotifierProvider.autoDispose<PostListViewModel, Result<List<Post>>>((ref) {
  final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
  final deletePostUseCase = ref.watch(deletePostUseCaseProvider);
  final viewModel = PostListViewModel(
    getPostsUseCase: getPostsUseCase,
    deletePostUseCase: deletePostUseCase,
  );

  viewModel.loadPosts();

  return viewModel;
});

/// 개별 게시글 Provider (ID 기반)
final postProvider = FutureProvider.family<Result<Post>, String>((ref, id) async {
  final useCase = ref.watch(getPostByIdUseCaseProvider);
  return await useCase(id);
});

/// autoDispose: 화면을 벗어나면 자동으로 dispose되어 메모리 효율성 향상
final postFormViewModelProvider = StateNotifierProvider.autoDispose<PostFormViewModel, PostFormState>((ref) {
  final createPostUseCase = ref.watch(createPostUseCaseProvider);
  final updatePostUseCase = ref.watch(updatePostUseCaseProvider);
  final getPostByIdUseCase = ref.watch(getPostByIdUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(auth_providers.getCurrentUserUseCaseProvider);
  return PostFormViewModel(
    createPostUseCase: createPostUseCase,
    updatePostUseCase: updatePostUseCase,
    getPostByIdUseCase: getPostByIdUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});

/// autoDispose: 화면을 벗어나면 자동으로 dispose되어 메모리 효율성 향상
final postDetailViewModelProvider = StateNotifierProvider.autoDispose.family<PostDetailViewModel, PostDetailState, String>((ref, postId) {
  final getPostByIdUseCase = ref.watch(getPostByIdUseCaseProvider);
  final getCommentsUseCase = ref.watch(getCommentsUseCaseProvider);
  final createCommentUseCase = ref.watch(createCommentUseCaseProvider);
  final toggleLikeUseCase = ref.watch(toggleLikeUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(auth_providers.getCurrentUserUseCaseProvider);
  final deleteCommentUseCase = ref.watch(deleteCommentUseCaseProvider);
  final getLikeCountUseCase = ref.watch(getLikeCountUseCaseProvider);

  final viewModel = PostDetailViewModel(
    getPostByIdUseCase: getPostByIdUseCase,
    getCommentsUseCase: getCommentsUseCase,
    createCommentUseCase: createCommentUseCase,
    deleteCommentUseCase: deleteCommentUseCase,
    toggleLikeUseCase: toggleLikeUseCase,
    getLikeCountUseCase: getLikeCountUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );

  viewModel.loadPost(postId);

  return viewModel;
});

/// autoDispose: 화면을 벗어나면 자동으로 dispose되어 메모리 효율성 향상
final likedPostsViewModelProvider = StateNotifierProvider.autoDispose<LikedPostsViewModel, Result<List<Post>>>((ref) {
  final getUserLikedPostsUseCase = ref.watch(getUserLikedPostsUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(auth_providers.getCurrentUserUseCaseProvider);
  final viewModel = LikedPostsViewModel(
    getUserLikedPostsUseCase: getUserLikedPostsUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
  viewModel.loadLikedPosts();
  return viewModel;
});

/// 하위 호환성을 위한 별칭
final postListProvider = postListViewModelProvider;
final postFormProvider = postFormViewModelProvider;
final likedPostsProvider = likedPostsViewModelProvider;
