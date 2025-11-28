import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_comment_datasource.dart';


class SupabaseCommentRepository implements CommentRepository {
  final SupabaseCommentDatasource _commentDatasource;

  SupabaseCommentRepository(this._commentDatasource);

  @override
  Future<Result<List<Comment>>> getCommentsByPostId(String postId) async {
    return await _commentDatasource.getCommentsByPostId(postId);
  }

  @override
  Future<Result<Comment>> createComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    return await _commentDatasource.createComment(
      postId: postId,
      userId: userId,
      content: content,
    );
  }

  @override
  Future<Result<Comment>> updateComment({
    required String commentId,
    required String content,
  }) async {
    return await _commentDatasource.updateComment(
      commentId: commentId,
      content: content,
    );
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    return await _commentDatasource.deleteComment(commentId);
  }
}

