import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/search/domain/entities/search_results.dart';
import 'package:lionsns/features/search/domain/factories/repository_factory.dart';


class SearchUseCase {
  final RepositoryFactory _factory;

  SearchUseCase(this._factory);

  /// 통합 검색 실행
  Future<Result<SearchResults>> call(String query) {
    final searchRepository = _factory.createSearchRepository();
    return searchRepository.search(query);
  }
}

