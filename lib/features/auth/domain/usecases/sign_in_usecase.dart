import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';


class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// SNS 로그인 실행
  Future<Result<User?>> call(AuthProvider provider) {
    return _authRepository.snsLogin(provider);
  }
}

