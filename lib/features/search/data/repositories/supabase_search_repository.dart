import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/search/domain/entities/search_results.dart';
import 'package:lionsns/features/search/domain/repositories/search_repository.dart';
import 'package:lionsns/features/search/data/datasources/supabase_search_datasource.dart';


class SupabaseSearchRepository implements SearchRepository {
  final SupabaseSearchDatasource _datasource;

  SupabaseSearchRepository(this._datasource);

  @override
  Future<Result<SearchResults>> search(String query) async {
    return await _datasource.search(query);
  }
}

