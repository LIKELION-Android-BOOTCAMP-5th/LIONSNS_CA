import 'package:flutter/foundation.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_profile_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import 'package:lionsns/core/services/external/supabase_service.dart';
import 'package:lionsns/core/services/internal/auth_provider_service.dart';
import 'package:lionsns/core/utils/result.dart';

class SupabaseAuthDatasource {
  final SupabaseProfileDatasource _profileDatasource = SupabaseProfileDatasource();
  
  Future<Result<User?>> snsLogin(AuthProvider provider) async {
    try {
      Result<AuthResponse> result;

      switch (provider) {
        case AuthProvider.google:
          result = await AuthProviderService.loginWithGoogle();
          break;
        case AuthProvider.apple:
          result = await AuthProviderService.loginWithApple();
          break;
        case AuthProvider.kakao:
          result = await AuthProviderService.loginWithKakao();
          break;
        case AuthProvider.naver:
          result = await AuthProviderService.loginWithNaver();
          break;
      }

      if (result is Pending<AuthResponse>) {
        final message = result.message ?? 'OAuth 로그인 진행 중입니다. 브라우저에서 로그인을 완료해주세요.';
        return Pending<User?>(message);
      }
      return await result.when(
        success: (authResponse) async {
          final user = AuthProviderService.authResponseToUser(authResponse);
          await _syncProfile(user);
          _saveFcmToken();
          return Success<User?>(user);
        },
        failure: (message, error) {
          return Future.value(Failure<User?>(message, error));
        },
      );
    } catch (e) {
      return Failure<User?>('SNS 로그인에 실패했습니다: $e');
    }
  }

  Future<Result<User?>> getCurrentUser() async {
    try {
      debugPrint('[SupabaseAuthDatasource] getCurrentUser 시작');
      final supabaseUser = SupabaseService.currentUser;
      debugPrint('[SupabaseAuthDatasource] Supabase currentUser: ${supabaseUser?.id ?? "null"}');

      if (supabaseUser == null) {
        debugPrint('[SupabaseAuthDatasource] currentUser가 null - 로그인되지 않음');
        return Success<User?>(null);
      }

      // Supabase Session 확인
      final session = SupabaseService.client.auth.currentSession;
      debugPrint('[SupabaseAuthDatasource] Session: ${session != null ? "있음" : "없음"}');

      if (session == null) {
        debugPrint('[SupabaseAuthDatasource] Session이 null - 로그인되지 않음');
        return Success<User?>(null);
      }

      // user_profiles 테이블에서 프로필 조회
      debugPrint('[SupabaseAuthDatasource] user_profiles 조회 시작 - userId: ${supabaseUser.id}');
      final profileResult = await _profileDatasource.getProfile(supabaseUser.id);
      debugPrint('[SupabaseAuthDatasource] user_profiles 조회 완료 - 결과: ${profileResult.runtimeType}');

      // 프로필이 있는 경우
      if (profileResult is Success<User?>) {
        final profileUser = profileResult.data;
        debugPrint('[SupabaseAuthDatasource] 프로필 조회 성공 - profileUser: ${profileUser?.id ?? "null"}');
        if (profileUser != null) {
          // email은 auth.users에서 가져오기
          final user = User(
            id: profileUser.id,
            name: profileUser.name,
            email: supabaseUser.email ?? '',
            profileImageUrl: profileUser.profileImageUrl,
            provider: profileUser.provider,
            createdAt: profileUser.createdAt,
          );
          debugPrint('[SupabaseAuthDatasource] 프로필에서 User 생성 완료 - id: ${user.id}, name: ${user.name}');
          return Success<User?>(user);
        }
      } else if (profileResult is Failure<User?>) {
        debugPrint('[SupabaseAuthDatasource] 프로필 조회 실패: ${profileResult.message}');
      }

      // 프로필이 없거나 조회 실패한 경우 userMetadata에서 생성
      debugPrint('[SupabaseAuthDatasource] 프로필이 없음 - userMetadata에서 User 생성');
      debugPrint('[SupabaseAuthDatasource] userMetadata: ${supabaseUser.userMetadata}');
      debugPrint('[SupabaseAuthDatasource] appMetadata: ${supabaseUser.appMetadata}');

      // userMetadata에서 User 생성
      final user = User(
        id: supabaseUser.id,
        name: supabaseUser.userMetadata?['full_name'] as String? ??
            supabaseUser.userMetadata?['name'] as String? ??
            supabaseUser.email?.split('@')[0] ?? '사용자',
        email: supabaseUser.email ?? '',
        profileImageUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
        provider: _getProviderFromSupabaseUser(supabaseUser),
        createdAt: DateTime.parse(supabaseUser.createdAt),
      );
      debugPrint('[SupabaseAuthDatasource] userMetadata에서 User 생성 완료 - id: ${user.id}, name: ${user.name}, provider: ${user.provider}');

      // 프로필 동기화 (데이터베이스에 저장)
      try {
        debugPrint('[SupabaseAuthDatasource] 프로필 동기화 시작');
        await _syncProfile(user);
        debugPrint('[SupabaseAuthDatasource] 프로필 동기화 완료');
        
        // 프로필 저장 후 다시 조회하여 최신 정보 반환
        debugPrint('[SupabaseAuthDatasource] 동기화 후 프로필 재조회 시작');
        final savedProfileResult = await _profileDatasource.getProfile(user.id);
        debugPrint('[SupabaseAuthDatasource] 동기화 후 프로필 재조회 완료');
        
        if (savedProfileResult is Success<User?>) {
          final savedProfile = savedProfileResult.data;
          if (savedProfile != null) {
            debugPrint('[SupabaseAuthDatasource] 저장된 프로필 발견 - id: ${savedProfile.id}');
            // 저장된 프로필이 있으면 email을 추가하여 반환
            final savedUser = User(
              id: savedProfile.id,
              name: savedProfile.name,
              email: supabaseUser.email ?? '',
              profileImageUrl: savedProfile.profileImageUrl,
              provider: savedProfile.provider,
              createdAt: savedProfile.createdAt,
            );
            return Success<User?>(savedUser);
          }
        }
      } catch (e, stackTrace) {
        // 프로필 동기화 실패해도 로그인은 가능
        debugPrint('[SupabaseAuthDatasource] 프로필 동기화 실패: $e');
        debugPrint('[SupabaseAuthDatasource] 스택 트레이스: $stackTrace');
      }

      // 프로필 저장 실패했어도 userMetadata에서 만든 User 반환
      debugPrint('[SupabaseAuthDatasource] userMetadata에서 만든 User 반환 - id: ${user.id}');
      return Success<User?>(user);
    } catch (e) {
      return Failure<User?>('사용자 정보를 불러오는데 실패했습니다: $e');
    }
  }
  
  Future<void> _syncProfile(User user) async {
    try {
      await _profileDatasource.upsertProfile(
        userId: user.id,
        name: user.name,
        email: user.email,
        profileImageUrl: user.profileImageUrl,
        provider: user.provider,
      );
    } catch (e, stackTrace) {
      // 프로필 동기화 실패는 로그인을 막지 않음
      debugPrint('[SupabaseAuthDatasource] 프로필 동기화 실패: $e');
    }
  }

  void _saveFcmToken() {
    // 비동기 작업이므로 await하지 않음 (로그인 속도에 영향 없도록)
    // PushNotificationService.getToken().then((token) {
    //   if (token != null) {
    //     PushNotificationService.saveTokenToSupabase(token);
    //   }
    // }).catchError((error) {
    //   // 토큰 저장 실패는 로그인을 막지 않음
    // });
  }

  Future<Result<void>> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
      return Success<void>(null as dynamic);
    } catch (e) {
      return Failure<void>('로그아웃에 실패했습니다: $e');
    }
  }

  /// 현재 로그인된 사용자 ID 조회 (동기)
  /// 로그인되지 않은 경우 null 반환
  String? getCurrentUserId() {
    return SupabaseService.currentUser?.id;
  }

  /// 인증 상태 변경 스트림
  Stream<AuthStateChange> get authStateChanges {
    return SupabaseService.authStateChanges.map((authState) {
      final supabaseEvent = authState.event;
      // Supabase의 AuthChangeEvent를 문자열로 비교
      final eventString = supabaseEvent.toString();
      if (eventString.contains('signedIn')) {
        return AuthStateChange(AuthChangeEvent.signedIn);
      } else if (eventString.contains('signedOut')) {
        return AuthStateChange(AuthChangeEvent.signedOut);
      } else if (eventString.contains('tokenRefreshed')) {
        return AuthStateChange(AuthChangeEvent.tokenRefreshed);
      } else if (eventString.contains('userUpdated')) {
        return AuthStateChange(AuthChangeEvent.userUpdated);
      } else {
        return AuthStateChange(AuthChangeEvent.signedOut);
      }
    });
  }

  AuthProvider _getProviderFromSupabaseUser(supabase.User supabaseUser) {
    final appMetadata = supabaseUser.appMetadata;
    final provider = appMetadata['provider'] as String?;
    final providerName = provider ?? 'email';

    switch (providerName) {
      case 'google':
        return AuthProvider.google;
      case 'apple':
        return AuthProvider.apple;
      case 'kakao':
        return AuthProvider.kakao;
      case 'naver':
        return AuthProvider.naver;
      default:
        return AuthProvider.google;
    }
  }
}

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

