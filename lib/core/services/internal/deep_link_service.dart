import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/config/router.dart';

/// Deep Link 처리 서비스
/// Android 네이티브에서 받은 deep link를 Flutter 라우터로 전달
class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('com.lionsns/deep_link');
  static GoRouter? _router;
  static String? _pendingPath;
  static String? _initialDeepLinkPath;
  static Timer? _retryTimer;
  
  /// 초기 딥링크 경로 설정
  static void setInitialDeepLink(String? path) {
    debugPrint('[DeepLinkService] setInitialDeepLink - path: $path');
    _initialDeepLinkPath = path;
  }
  
  /// 초기 딥링크 경로 가져오기
  static String? getInitialDeepLink() {
    final path = _initialDeepLinkPath;
    debugPrint('[DeepLinkService] getInitialDeepLink - path: $path');
    _initialDeepLinkPath = null;
    return path;
  }

  /// 라우터 등록
  static void initialize(GoRouter router) {
    debugPrint('[DeepLinkService] initialize - router 등록');
    _router = router;
    _setupListener();
    
    if (_pendingPath != null) {
      debugPrint('[DeepLinkService] pending path 처리: $_pendingPath');
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToPath(_pendingPath!);
        _pendingPath = null;
      });
    }
  }

  /// MethodChannel 리스너 설정
  static void _setupListener() {
    debugPrint('[DeepLinkService] MethodChannel 리스너 설정');
    _channel.setMethodCallHandler((call) async {
      debugPrint('[DeepLinkService] MethodChannel 호출 - method: ${call.method}, arguments: ${call.arguments}');
      if (call.method == 'handleDeepLink' && call.arguments != null) {
        final path = call.arguments as String;
        debugPrint('[DeepLinkService] handleDeepLink - path: $path');
        _navigateToPath(path);
      } else if (call.method == 'setInitialDeepLink' && call.arguments != null) {
        final path = call.arguments as String;
        debugPrint('[DeepLinkService] setInitialDeepLink - path: $path');
        setInitialDeepLink(path);
      }
    });
  }

  /// 경로로 이동
  static void _navigateToPath(String path, {int retryCount = 0}) {
    debugPrint('[DeepLinkService] _navigateToPath 시작 - path: $path, retryCount: $retryCount');
    
    if (_router == null) {
      debugPrint('[DeepLinkService] router가 null - 재시도 예약');
      if (retryCount < 10) {
        _pendingPath = path;
        _retryTimer?.cancel();
        _retryTimer = Timer(Duration(milliseconds: 300 + (retryCount * 100)), () {
          _navigateToPath(path, retryCount: retryCount + 1);
        });
      } else {
        debugPrint('[DeepLinkService] 최대 재시도 횟수 초과 - 포기');
        _pendingPath = null;
      }
      return;
    }

    _retryTimer?.cancel();
    _pendingPath = null;

    try {
      debugPrint('[DeepLinkService] 경로 이동 시도 - path: $path');
      if (path.startsWith('/post/')) {
        String? currentLocation;
        try {
          currentLocation = _router!.routerDelegate.currentConfiguration.uri.path;
        } catch (e) {
          debugPrint('[DeepLinkService] 현재 위치 조회 실패: $e');
        }
        
        if (currentLocation == null || currentLocation != AppRoutes.home) {
          debugPrint('[DeepLinkService] 홈으로 이동 후 게시글 상세로 이동');
          _router!.go(AppRoutes.home);
          Future.delayed(const Duration(milliseconds: 150), () {
            _router!.push(path);
          });
        } else {
          debugPrint('[DeepLinkService] 게시글 상세로 직접 이동');
          _router!.push(path);
        }
      } else if (path == '/login') {
        debugPrint('[DeepLinkService] 로그인 화면으로 이동');
        _router!.go(path);
      } else {
        debugPrint('[DeepLinkService] 홈으로 이동');
        _router!.go('/');
      }
      debugPrint('[DeepLinkService] 경로 이동 완료');
    } catch (e, stackTrace) {
      debugPrint('[DeepLinkService] 경로 이동 실패: $e');
      debugPrint('[DeepLinkService] 스택 트레이스: $stackTrace');
      if (retryCount < 5) {
        debugPrint('[DeepLinkService] 재시도 예약 - retryCount: $retryCount');
        Future.delayed(Duration(milliseconds: 500), () {
          _navigateToPath(path, retryCount: retryCount + 1);
        });
      } else {
        debugPrint('[DeepLinkService] 최대 재시도 횟수 초과 - 포기');
      }
    }
  }
}

