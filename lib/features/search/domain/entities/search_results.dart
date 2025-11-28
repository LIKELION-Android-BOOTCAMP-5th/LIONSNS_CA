import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';

/// 검색 결과 엔티티
class SearchResults {
  final List<Post> posts;
  final List<Comment> comments;
  final List<User> users;

  const SearchResults({
    required this.posts,
    required this.comments,
    required this.users,
  });
}

