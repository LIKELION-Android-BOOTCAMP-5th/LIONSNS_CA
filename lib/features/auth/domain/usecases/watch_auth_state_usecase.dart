import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';


class WatchAuthStateUseCase {
  final AuthRepository _authRepository;

  WatchAuthStateUseCase(this._authRepository);

  /// 인증 상태 변경 스트림
  Stream<AuthStateChange> call() {
    return _authRepository.authStateChanges;
  }
}

