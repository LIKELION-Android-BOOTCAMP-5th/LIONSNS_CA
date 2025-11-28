import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_profile_datasource.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_follow_datasource.dart';

final supabaseAuthDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
  return SupabaseAuthDatasource();
});

final supabaseProfileDatasourceProvider = Provider<SupabaseProfileDatasource>((ref) {
  return SupabaseProfileDatasource();
});

final supabaseFollowDatasourceProvider = Provider<SupabaseFollowDatasource>((ref) {
  return SupabaseFollowDatasource();
});
