import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/search/domain/entities/search_results.dart';


abstract class SearchRepository {
  /// 통합 검색 (포스트, 댓글, 사용자)
  Future<Result<SearchResults>> search(String query);
}

