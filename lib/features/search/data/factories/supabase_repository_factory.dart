import 'package:lionsns/features/search/domain/factories/repository_factory.dart';
import 'package:lionsns/features/search/domain/repositories/search_repository.dart';
import 'package:lionsns/features/search/data/repositories/supabase_search_repository.dart';
import 'package:lionsns/features/search/data/datasources/supabase_search_datasource.dart';

class SupabaseRepositoryFactory implements RepositoryFactory {
  final SupabaseSearchDatasource _datasource;

  SupabaseRepositoryFactory(this._datasource);

  @override
  SearchRepository createSearchRepository() {
    return SupabaseSearchRepository(_datasource);
  }
}

