import 'package:lionsns/features/auth/domain/factories/repository_factory.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';
import 'package:lionsns/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:lionsns/features/auth/data/repositories/supabase_profile_repository.dart';
import 'package:lionsns/features/auth/data/repositories/supabase_follow_repository.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_profile_datasource.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_follow_datasource.dart';

class SupabaseRepositoryFactory implements RepositoryFactory {
  final SupabaseAuthDatasource _authDatasource;
  final SupabaseProfileDatasource _profileDatasource;
  final SupabaseFollowDatasource _followDatasource;

  SupabaseRepositoryFactory({
    required SupabaseAuthDatasource authDatasource,
    required SupabaseProfileDatasource profileDatasource,
    required SupabaseFollowDatasource followDatasource,
  })  : _authDatasource = authDatasource,
        _profileDatasource = profileDatasource,
        _followDatasource = followDatasource;

  @override
  AuthRepository createAuthRepository() {
    final profileRepository = createProfileRepository();
    return SupabaseAuthRepository(
      authDatasource: _authDatasource,
      profileRepository: profileRepository,
    );
  }

  @override
  ProfileRepository createProfileRepository() {
    return SupabaseProfileRepository(_profileDatasource);
  }

  @override
  FollowRepository createFollowRepository() {
    return SupabaseFollowRepository(_followDatasource);
  }
}

