import 'dart:async';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';

/// Supabase를 Firebase로 교체할 때의 구현 예시
/// 
/// ViewModel과 다른 코드는 변경할 필요가 없습니다.
class FirebaseAuthRepository implements AuthRepository {
  final ProfileRepository _profileRepository;

  FirebaseAuthRepository({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  @override
  Future<Result<User?>> snsLogin(AuthProvider provider) async {
    // Firebase 인증 로직 구현
    // 예: await FirebaseAuth.instance.signInWithPopup(...)
    // TODO: Firebase 구현
    throw UnimplementedError('Firebase 구현 필요');
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    // Firebase 현재 사용자 조회
    // 예: FirebaseAuth.instance.currentUser
    // TODO: Firebase 구현
    throw UnimplementedError('Firebase 구현 필요');
  }

  @override
  String? getCurrentUserId() {
    // Firebase 현재 사용자 ID 조회
    // 예: FirebaseAuth.instance.currentUser?.uid
    // TODO: Firebase 구현
    throw UnimplementedError('Firebase 구현 필요');
  }

  @override
  Stream<AuthStateChange> get authStateChanges {
    // Firebase 인증 상태 변경 스트림
    // 예: FirebaseAuth.instance.authStateChanges().map(...)
    // TODO: Firebase 구현
    throw UnimplementedError('Firebase 구현 필요');
  }

  @override
  Future<Result<void>> logout() async {
    // Firebase 로그아웃
    // 예: await FirebaseAuth.instance.signOut();
    // TODO: Firebase 구현
    throw UnimplementedError('Firebase 구현 필요');
  }
}

