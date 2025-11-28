import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';


class UpdateProfileUseCase {
  final ProfileRepository _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  /// 프로필 업데이트
  Future<Result<User>> call({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) {
    return _profileRepository.updateProfile(
      userId: userId,
      name: name,
      profileImageUrl: profileImageUrl,
    );
  }
}

