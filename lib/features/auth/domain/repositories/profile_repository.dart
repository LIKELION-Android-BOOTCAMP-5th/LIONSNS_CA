import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  /// 프로필 조회
  Future<Result<User?>> getProfile(String userId);

  /// 프로필 생성 또는 업데이트
  Future<Result<User>> upsertProfile({
    required String userId,
    required String name,
    required String email,
    String? profileImageUrl,
    required AuthProvider provider,
  });

  /// 프로필 업데이트
  Future<Result<User>> updateProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  });
}

