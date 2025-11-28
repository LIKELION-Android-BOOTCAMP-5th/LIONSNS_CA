import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/search/data/datasources/supabase_search_datasource.dart';

final searchDatasourceProvider = Provider<SupabaseSearchDatasource>((ref) {
  return SupabaseSearchDatasource();
});

