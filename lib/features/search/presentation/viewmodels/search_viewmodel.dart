import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/search/domain/entities/search_results.dart';
import 'package:lionsns/features/search/domain/usecases/search_usecase.dart';

class SearchViewModel extends StateNotifier<Result<SearchResults>> {
  final SearchUseCase _searchUseCase;

  SearchViewModel({
    required SearchUseCase searchUseCase,
  })  : _searchUseCase = searchUseCase,
        super(const Success<SearchResults>(SearchResults(
          posts: [],
          comments: [],
          users: [],
        )));

  /// 검색 실행
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const Success<SearchResults>(SearchResults(
        posts: [],
        comments: [],
        users: [],
      ));
      return;
    }

    state = const Pending<SearchResults>();
    final result = await _searchUseCase(query);
    state = result;
  }

  /// 검색 초기화
  void clear() {
    state = const Success<SearchResults>(SearchResults(
      posts: [],
      comments: [],
      users: [],
    ));
  }
}

