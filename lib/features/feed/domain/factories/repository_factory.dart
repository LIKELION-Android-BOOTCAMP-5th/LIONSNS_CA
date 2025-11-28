import 'package:lionsns/features/feed/domain/repositories/post_repository.dart';
import 'package:lionsns/features/feed/domain/repositories/comment_repository.dart';
import 'package:lionsns/features/feed/domain/repositories/like_repository.dart';

/// Domain 레이어가 Data 레이어를 직접 import하지 않도록 하는 인터페이스
abstract class RepositoryFactory {
  /// PostRepository 생성
  PostRepository createPostRepository();

  /// CommentRepository 생성
  CommentRepository createCommentRepository();

  /// LikeRepository 생성
  LikeRepository createLikeRepository();
}

