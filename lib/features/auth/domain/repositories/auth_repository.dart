import 'dart:async';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';

/// 인증 상태 변경 이벤트
enum AuthChangeEvent {
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
}

/// 인증 상태 변경 데이터
class AuthStateChange {
  final AuthChangeEvent event;

  AuthStateChange(this.event);
}

/// 백엔드 서비스(Supabase, Firebase 등)에 독립적인 추상화 제공
/// 
/// 백엔드를 교체할 때는 이 인터페이스를 구현하는 새로운 Repository만 만들면 됩니다.
abstract class AuthRepository {
  /// SNS 로그인
  Future<Result<User?>> snsLogin(AuthProvider provider);

  /// 현재 로그인된 사용자 조회
  Future<Result<User?>> getCurrentUser();

  /// 현재 로그인된 사용자 ID 조회 (동기)
  /// 로그인되지 않은 경우 null 반환
  String? getCurrentUserId();

  /// 인증 상태 변경 스트림
  /// 로그인, 로그아웃, 토큰 갱신 등의 이벤트를 감지
  Stream<AuthStateChange> get authStateChanges;

  /// 로그아웃
  Future<Result<void>> logout();
}

