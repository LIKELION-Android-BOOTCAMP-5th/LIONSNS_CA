import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_profile_datasource.dart';


class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseProfileDatasource _profileDatasource;

  SupabaseProfileRepository(this._profileDatasource);

  @override
  Future<Result<User?>> getProfile(String userId) async {
    return await _profileDatasource.getProfile(userId);
  }

  @override
  Future<Result<User>> upsertProfile({
    required String userId,
    required String name,
    required String email,
    String? profileImageUrl,
    required AuthProvider provider,
  }) async {
    return await _profileDatasource.upsertProfile(
      userId: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      provider: provider,
    );
  }

  @override
  Future<Result<User>> updateProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    return await _profileDatasource.updateProfile(
      userId: userId,
      name: name,
      profileImageUrl: profileImageUrl,
    );
  }
}

