import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';


class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  /// 로그아웃 실행
  Future<Result<void>> call() {
    return _authRepository.logout();
  }
}

