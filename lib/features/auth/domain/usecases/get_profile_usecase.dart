import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';


class GetProfileUseCase {
  final ProfileRepository _profileRepository;

  GetProfileUseCase(this._profileRepository);

  /// 프로필 조회
  Future<Result<User?>> call(String userId) {
    return _profileRepository.getProfile(userId);
  }
}

