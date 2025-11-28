import 'package:lionsns/core/utils/result.dart';

abstract class LikeRepository {
  /// 게시글 좋아요 수 가져오기
  Future<Result<int>> getLikeCount(String postId);

  /// 사용자가 게시글을 좋아요 했는지 확인
  Future<Result<bool>> isLiked(String postId, String userId);

  /// 좋아요 추가
  Future<Result<void>> addLike(String postId, String userId);

  /// 좋아요 제거
  Future<Result<void>> removeLike(String postId, String userId);

  /// 좋아요 토글 (추가/제거)
  Future<Result<bool>> toggleLike(String postId, String userId);
}

