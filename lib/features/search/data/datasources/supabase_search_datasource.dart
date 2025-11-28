import 'package:lionsns/core/services/external/supabase_service.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/domain/entities/post.dart';
import 'package:lionsns/features/feed/domain/entities/comment.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart' show User, AuthProvider;
import 'package:lionsns/features/search/domain/entities/search_results.dart';
import 'package:lionsns/features/feed/data/dtos/post_dto.dart';
import 'package:lionsns/features/feed/data/dtos/comment_dto.dart';

class SupabaseSearchDatasource {
  /// 통합 검색 (포스트, 댓글, 사용자)
  Future<Result<SearchResults>> search(String query) async {
    if (query.trim().isEmpty) {
      return Success<SearchResults>(const SearchResults(
        posts: [],
        comments: [],
        users: [],
      ));
    }

    try {
      final searchTerm = '%$query%';

      // 포스트 검색 (제목, 내용)
      final postsResponse = await SupabaseService.client
          .from('posts')
          .select('*, user_profiles!user_id(name, profile_image_url)')
          .or('title.ilike.$searchTerm,content.ilike.$searchTerm')
          .order('created_at', ascending: false)
          .limit(20);

      // 댓글 검색 (내용)
      final commentsResponse = await SupabaseService.client
          .from('comments')
          .select('*, user_profiles!user_id(name, profile_image_url), posts!post_id(id, title)')
          .ilike('content', searchTerm)
          .order('created_at', ascending: false)
          .limit(20);

      // 사용자 검색 (이름)
      final usersResponse = await SupabaseService.client
          .from('user_profiles')
          .select()
          .ilike('name', searchTerm)
          .limit(20);

      // 포스트 변환
      final posts = <Post>[];
      if (postsResponse is List) {
        for (final json in postsResponse) {
          try {
            final data = Map<String, dynamic>.from(json);
            final postDto = PostDto.fromJson(data);
            
            // 프로필 정보
            String? authorName;
            String? authorImageUrl;
            final userProfile = data['user_profiles'];
            if (userProfile != null && userProfile is Map<String, dynamic>) {
              authorName = userProfile['name'] as String?;
              authorImageUrl = userProfile['profile_image_url'] as String?;
            }

            // 좋아요 수
            final likesResponse = await SupabaseService.client
                .from('post_likes')
                .select()
                .eq('post_id', postDto.id);
            final likesCount = (likesResponse as List).length;

            // 댓글 수
            int commentsCount = 0;
            try {
              final commentsResponse = await SupabaseService.client
                  .from('comments')
                  .select('id')
                  .eq('post_id', postDto.id);
              commentsCount = (commentsResponse as List).length;
            } catch (e) {
              // 댓글 수 조회 실패 시 0으로 처리
            }

            final post = postDto.toEntity().copyWith(
              authorName: authorName,
              authorImageUrl: authorImageUrl,
              likesCount: likesCount,
              commentsCount: commentsCount,
            );
            posts.add(post);
          } catch (e) {
            // 포스트 변환 실패 시 건너뜀
          }
        }
      }

      // 댓글 변환
      final comments = <Comment>[];
      if (commentsResponse is List) {
        for (final json in commentsResponse) {
          try {
            final data = Map<String, dynamic>.from(json);
            final commentDto = CommentDto.fromJson(data);
            
            // 작성자 정보
            String? authorName;
            String? authorImageUrl;
            final userProfile = data['user_profiles'];
            if (userProfile != null && userProfile is Map<String, dynamic>) {
              authorName = userProfile['name'] as String?;
              authorImageUrl = userProfile['profile_image_url'] as String?;
            }

            // 게시글 정보
            String? postTitle;
            final postData = data['posts'];
            if (postData != null && postData is Map<String, dynamic>) {
              postTitle = postData['title'] as String?;
            }

            final comment = commentDto.toEntity().copyWith(
              authorName: authorName,
              authorImageUrl: authorImageUrl,
              postTitle: postTitle,
            );
            comments.add(comment);
          } catch (e) {
            // 댓글 변환 실패 시 건너뜀
          }
        }
      }
      
      final users = <User>[];
      if (usersResponse is List) {
        for (final json in usersResponse) {
          try {
            final profile = Map<String, dynamic>.from(json);
            final user = User(
              id: profile['id'] as String,
              name: profile['name'] as String? ?? '사용자',
              email: '', // 검색에서는 email 불필요
              profileImageUrl: profile['profile_image_url'] as String?,
              provider: _getProviderFromString(profile['provider'] as String?),
              createdAt: DateTime.parse(profile['created_at'] as String),
            );
            users.add(user);
          } catch (e) {
            // 사용자 변환 실패 시 건너뜀
          }
        }
      }

      final result = SearchResults(
        posts: posts,
        comments: comments,
        users: users,
      );
      
      return Success<SearchResults>(result);
    } catch (e, stackTrace) {
      return Failure<SearchResults>('검색에 실패했습니다: $e');
    }
  }

  AuthProvider _getProviderFromString(String? provider) {
    switch (provider) {
      case 'google':
        return AuthProvider.google;
      case 'apple':
        return AuthProvider.apple;
      case 'kakao':
        return AuthProvider.kakao;
      case 'naver':
        return AuthProvider.naver;
      default:
        return AuthProvider.google;
    }
  }
}

