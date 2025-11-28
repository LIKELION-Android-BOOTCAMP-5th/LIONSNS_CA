import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/usecases/get_post_by_id_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_comments_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/create_comment_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_like_count_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';

/// 게시글 상세 상태
class PostDetailState {
  final Result<Post>? postResult;
  final Result<List<Comment>>? commentsResult;
  final bool isLoading;
  final bool isLiking;
  final bool isCommenting;
  final String? errorMessage;

  const PostDetailState({
    this.postResult,
    this.commentsResult,
    this.isLoading = false,
    this.isLiking = false,
    this.isCommenting = false,
    this.errorMessage,
  });

  PostDetailState copyWith({
    Result<Post>? postResult,
    Result<List<Comment>>? commentsResult,
    bool? isLoading,
    bool? isLiking,
    bool? isCommenting,
    String? errorMessage,
  }) {
    return PostDetailState(
      postResult: postResult ?? this.postResult,
      commentsResult: commentsResult ?? this.commentsResult,
      isLoading: isLoading ?? this.isLoading,
      isLiking: isLiking ?? this.isLiking,
      isCommenting: isCommenting ?? this.isCommenting,
      errorMessage: errorMessage,
    );
  }
}

class PostDetailViewModel extends StateNotifier<PostDetailState> {
  final GetPostByIdUseCase _getPostByIdUseCase;
  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final GetLikeCountUseCase _getLikeCountUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  PostDetailViewModel({
    required GetPostByIdUseCase getPostByIdUseCase,
    required GetCommentsUseCase getCommentsUseCase,
    required CreateCommentUseCase createCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required GetLikeCountUseCase getLikeCountUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _getPostByIdUseCase = getPostByIdUseCase,
        _getCommentsUseCase = getCommentsUseCase,
        _createCommentUseCase = createCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase,
        _toggleLikeUseCase = toggleLikeUseCase,
        _getLikeCountUseCase = getLikeCountUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const PostDetailState());

  /// 게시글 및 댓글 로드
  Future<void> loadPost(String postId) async {
    state = state.copyWith(isLoading: true);

    final postResult = await _getPostByIdUseCase(postId);
    final commentsResult = await _getCommentsUseCase(postId);

    state = state.copyWith(
      postResult: postResult,
      commentsResult: commentsResult,
      isLoading: false,
    );
  }

  /// 좋아요 토글
  Future<void> toggleLike(String postId) async {
    final currentUserId = _getCurrentUserUseCase.getCurrentUserId();
    if (currentUserId == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다');
      return;
    }

    // 현재 게시글 상태 가져오기
    final currentPost = state.postResult?.when(
      success: (post) => post,
      failure: (_, __) => null,
      pending: (_) => null,
    );

    if (currentPost == null) {
      return;
    }

    // 즉시 UI 업데이트 (낙관적 업데이트)
    final newIsLiked = !(currentPost.isLiked ?? false);
    final newLikesCount = (currentPost.likesCount ?? 0) + (newIsLiked ? 1 : -1);

    state = state.copyWith(
      isLiking: true,
      errorMessage: null,
      postResult: Success<Post>(
        currentPost.copyWith(
          isLiked: newIsLiked,
          likesCount: newLikesCount < 0 ? 0 : newLikesCount,
        ),
      ),
    );

    final result = await _toggleLikeUseCase(postId, currentUserId);

    result.when(
      success: (finalIsLiked) async {
        // 성공 시 서버에서 좋아요 수만 가져와서 업데이트 (전체 게시글 다시 로드하지 않음)
        final likeCountResult = await _getLikeCountUseCase(postId);
        likeCountResult.when(
          success: (likeCount) {
            // 좋아요 수만 업데이트하여 해당 영역만 갱신
            final updatedPost = currentPost.copyWith(
              isLiked: finalIsLiked,
              likesCount: likeCount,
            );
            state = state.copyWith(
              isLiking: false,
              postResult: Success<Post>(updatedPost),
            );
          },
          failure: (_, __) {
            // 좋아요 수 조회 실패 시 Optimistic UI 상태 유지
            state = state.copyWith(
              isLiking: false,
              postResult: Success<Post>(
                currentPost.copyWith(
                  isLiked: finalIsLiked,
                  likesCount: newLikesCount < 0 ? 0 : newLikesCount,
                ),
              ),
            );
          },
        );
      },
      failure: (message, _) {
        // 실패 시 원래 상태로 되돌리기
        state = state.copyWith(
          isLiking: false,
          errorMessage: message,
          postResult: Success<Post>(currentPost),
        );
      },
    );
  }

  /// 댓글 작성
  Future<void> addComment(String postId, String content) async {
    final currentUserId = _getCurrentUserUseCase.getCurrentUserId();
    if (currentUserId == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다');
      return;
    }

    // 현재 게시글 및 댓글 상태 가져오기
    final currentPost = state.postResult?.when(
      success: (post) => post,
      failure: (_, __) => null,
      pending: (_) => null,
    );
    final currentComments = state.commentsResult?.when(
      success: (comments) => comments,
      failure: (_, __) => null,
      pending: (_) => null,
    ) ?? [];

    state = state.copyWith(
      isCommenting: true,
      errorMessage: null,
    );

    final result = await _createCommentUseCase(
      postId: postId,
      userId: currentUserId,
      content: content,
    );

    result.when(
      success: (newComment) {
        // Optimistic UI: 댓글 목록에 즉시 추가
        // 서버에서 이미 생성된 댓글이 반환되므로, 즉시 UI에 추가
        final updatedComments = [...currentComments, newComment];
        state = state.copyWith(
          isCommenting: false,
          commentsResult: Success<List<Comment>>(updatedComments),
          // 게시글의 댓글 수만 업데이트 (전체 게시글 다시 로드하지 않음)
          postResult: currentPost != null
              ? Success<Post>(
                  currentPost.copyWith(
                    commentsCount: (currentPost.commentsCount ?? 0) + 1,
                  ),
                )
              : state.postResult,
        );
        // 백그라운드 동기화 불필요: 서버에서 이미 생성된 댓글이 반환되었으므로
        // Optimistic UI 업데이트로 충분함
      },
      failure: (message, _) {
        state = state.copyWith(
          isCommenting: false,
          errorMessage: message,
        );
      },
    );
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId, String postId) async {
    // 현재 게시글 및 댓글 상태 가져오기
    final currentPost = state.postResult?.when(
      success: (post) => post,
      failure: (_, __) => null,
      pending: (_) => null,
    );
    final currentComments = state.commentsResult?.when(
      success: (comments) => comments,
      failure: (_, __) => null,
      pending: (_) => null,
    ) ?? [];

    // Optimistic UI: 댓글 목록에서 즉시 제거
    final updatedComments = currentComments.where((c) => c.id != commentId).toList();
    state = state.copyWith(
      commentsResult: Success<List<Comment>>(updatedComments),
      // 게시글의 댓글 수만 업데이트 (전체 게시글 다시 로드하지 않음)
      postResult: currentPost != null
          ? Success<Post>(
              currentPost.copyWith(
                commentsCount: (currentPost.commentsCount ?? 0) - 1 < 0
                    ? 0
                    : (currentPost.commentsCount ?? 0) - 1,
              ),
            )
          : state.postResult,
    );

    final result = await _deleteCommentUseCase(commentId);

    result.when(
      success: (_) {
        // Optimistic UI 업데이트로 이미 댓글이 삭제되었으므로
        // 추가 동기화 불필요 (댓글 목록과 게시글 댓글 수는 이미 업데이트됨)
        // 실패하지 않았으므로 에러 메시지 제거
        state = state.copyWith(errorMessage: null);
      },
      failure: (message, _) {
        // 실패 시 원래 댓글 목록으로 되돌리기
        state = state.copyWith(
          errorMessage: message,
          commentsResult: Success<List<Comment>>(currentComments),
          postResult: currentPost != null
              ? Success<Post>(currentPost)
              : state.postResult,
        );
      },
    );
  }

}


