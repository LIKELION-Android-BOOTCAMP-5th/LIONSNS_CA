import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';


class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// 현재 사용자 조회
  Future<Result<User?>> call() {
    return _authRepository.getCurrentUser();
  }

  /// 현재 사용자 ID 조회 (동기)
  String? getCurrentUserId() {
    return _authRepository.getCurrentUserId();
  }
}

