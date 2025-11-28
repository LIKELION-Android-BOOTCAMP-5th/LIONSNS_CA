import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/auth/domain/factories/repository_factory.dart';
import 'package:lionsns/features/auth/data/factories/supabase_repository_factory.dart';
import '../datasource_providers.dart';

/// Domain 레이어의 Factory 인터페이스를 반환하여 의존성 역전 원칙 준수
final repositoryFactoryProvider = Provider<RepositoryFactory>((ref) {
  final authDatasource = ref.watch(supabaseAuthDatasourceProvider);
  final profileDatasource = ref.watch(supabaseProfileDatasourceProvider);
  final followDatasource = ref.watch(supabaseFollowDatasourceProvider);
  return SupabaseRepositoryFactory(
    authDatasource: authDatasource,
    profileDatasource: profileDatasource,
    followDatasource: followDatasource,
  );
});

