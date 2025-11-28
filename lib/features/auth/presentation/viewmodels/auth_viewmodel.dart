import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/core/services/internal/widget_update_service.dart';
import 'package:lionsns/core/services/internal/push_notification_service.dart';
import 'package:lionsns/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart';

enum AuthState {
  unauthenticated,
  authenticated,
  loading,
}

class AuthViewModel extends StateNotifier<Result<User?>> {
  final SignInUseCase _signInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final WatchAuthStateUseCase _watchAuthStateUseCase;
  final WidgetUpdateService? _widgetUpdateService;
  StreamSubscription? _authStateSubscription;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required WatchAuthStateUseCase watchAuthStateUseCase,
    WidgetUpdateService? widgetUpdateService,
  })  : _signInUseCase = signInUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        _watchAuthStateUseCase = watchAuthStateUseCase,
        _widgetUpdateService = widgetUpdateService,
        super(Success<User?>(null)) {
    _loadCurrentUser();
    _listenToAuthStateChanges();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// 소셜 로그인 실행
  Future<void> signIn(AuthProvider provider) async {
    state = Pending<User?>('OAuth 로그인 진행 중...');
    final result = await _signInUseCase(provider);

    result.when(
      success: (user) {},
      failure: (message, error) {
        debugPrint('SNS 로그인 실패: $message');
      },
      pending: (message) {},
    );

    state = result;
  }

  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase();

    result.when(
      success: (user) {
        if (user != null) {
          _widgetUpdateService?.updateWidget();
          _saveFcmToken();
        }
      },
      failure: (message, error) {
        debugPrint('사용자 로드 실패: $message');
      },
      pending: (_) {},
    );

    try {
      state = result;
    } catch (e) {
      // dispose된 상태에서 상태 업데이트 시도 방지
    }
  }

  void _listenToAuthStateChanges() {
    _authStateSubscription = _watchAuthStateUseCase().listen(
      (authStateChange) {
        if (authStateChange.event == AuthChangeEvent.signedIn) {
          _loadCurrentUser().then((_) {
            _widgetUpdateService?.updateWidget();
            _saveFcmToken();
            Future.delayed(const Duration(seconds: 1), () {
              _widgetUpdateService?.updateWidget();
            });
          });
        } else if (authStateChange.event == AuthChangeEvent.signedOut) {
          try {
            state = Success<User?>(null);
            _widgetUpdateService?.clearWidget();
          } catch (e) {
            // dispose된 상태에서 상태 업데이트 시도 무시
          }
        } else if (authStateChange.event == AuthChangeEvent.tokenRefreshed) {
          _loadCurrentUser().then((_) {
            _widgetUpdateService?.updateWidget();
            _saveFcmToken();
          });
        } else if (authStateChange.event == AuthChangeEvent.userUpdated) {
          _loadCurrentUser().then((_) {
            _widgetUpdateService?.updateWidget();
          });
        }
      },
      onError: (error) {
        // Deep link 처리 중 발생하는 오류는 무시
      },
    );
  }

  String _getProviderName(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.kakao:
        return '카카오';
      case AuthProvider.naver:
        return '네이버';
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    final result = await _logoutUseCase();
    result.when(
      success: (_) {
        try {
          state = Success<User?>(null);
        } catch (e) {
          // dispose된 상태에서 상태 업데이트 시도 무시
        }
      },
      failure: (message, error) {
        debugPrint('로그아웃 실패: $message');
      },
      pending: (_) {},
    );
  }

  /// 인증 상태 새로고침
  Future<void> refresh() async {
    try {
      await _loadCurrentUser();
    } catch (e) {
      // dispose된 상태에서 refresh 시도 무시
    }
  }

  /// FCM 토큰 저장
  /// 
  /// 로그인 성공 시 또는 사용자 정보 로드 시 FCM 토큰을 Supabase에 저장합니다.
  void _saveFcmToken() {
    try {
      // 비동기로 처리하되 결과는 기다리지 않음 (실패해도 로그인 플로우에 영향 없음)
      PushNotificationService.getToken().then((token) {
        if (token != null) {
          PushNotificationService.saveTokenToSupabase(token);
        }
      }).catchError((error) {
        debugPrint('FCM 토큰 저장 실패: $error');
      });
    } catch (e) {
      // FCM 토큰 저장 실패는 무시
    }
  }
}
