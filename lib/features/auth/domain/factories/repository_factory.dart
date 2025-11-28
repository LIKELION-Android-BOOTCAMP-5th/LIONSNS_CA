import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';
import 'package:lionsns/features/auth/domain/repositories/follow_repository.dart';

/// Domain 레이어가 Data 레이어를 직접 import하지 않도록 하는 인터페이스
abstract class RepositoryFactory {
  /// AuthRepository 생성
  AuthRepository createAuthRepository();

  /// ProfileRepository 생성
  ProfileRepository createProfileRepository();

  /// FollowRepository 생성
  FollowRepository createFollowRepository();
}

