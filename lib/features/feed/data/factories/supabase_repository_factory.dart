import 'package:lionsns/features/feed/domain/factories/repository_factory.dart';
import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';
import 'package:lionsns/features/feed/data/repositories/supabase_post_repository.dart';
import 'package:lionsns/features/feed/data/repositories/supabase_comment_repository.dart';
import 'package:lionsns/features/feed/data/repositories/supabase_like_repository.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_post_datasource.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_comment_datasource.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_like_datasource.dart';

class SupabaseRepositoryFactory implements RepositoryFactory {
  final SupabasePostDatasource _postDatasource;
  final SupabaseCommentDatasource _commentDatasource;
  final SupabaseLikeDatasource _likeDatasource;

  SupabaseRepositoryFactory({
    required SupabasePostDatasource postDatasource,
    required SupabaseCommentDatasource commentDatasource,
    required SupabaseLikeDatasource likeDatasource,
  })  : _postDatasource = postDatasource,
        _commentDatasource = commentDatasource,
        _likeDatasource = likeDatasource;

  @override
  PostRepository createPostRepository() {
    return SupabasePostRepository(_postDatasource);
  }

  @override
  CommentRepository createCommentRepository() {
    return SupabaseCommentRepository(_commentDatasource);
  }

  @override
  LikeRepository createLikeRepository() {
    return SupabaseLikeRepository(_likeDatasource);
  }
}

