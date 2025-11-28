import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_post_datasource.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_comment_datasource.dart';
import 'package:lionsns/features/feed/data/datasources/supabase_like_datasource.dart';
import 'package:lionsns/core/services/internal/storage_service_provider.dart';

final postDatasourceProvider = Provider<SupabasePostDatasource>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SupabasePostDatasource(storageService);
});

final commentDatasourceProvider = Provider<SupabaseCommentDatasource>((ref) {
  return SupabaseCommentDatasource();
});

final likeDatasourceProvider = Provider<SupabaseLikeDatasource>((ref) {
  return SupabaseLikeDatasource();
});
