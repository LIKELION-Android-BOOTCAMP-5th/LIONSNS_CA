import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/l10n/app_localizations.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/core/services/internal/deep_link_service.dart';
import 'package:lionsns/core/services/external/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lionsns/features/auth/presentation/pages/auth_screen.dart';
import 'package:lionsns/features/auth/presentation/pages/profile_screen.dart';
import 'package:lionsns/features/auth/presentation/pages/profile_edit_screen.dart';
import 'package:lionsns/features/auth/presentation/providers/providers.dart';
import 'package:lionsns/features/feed/presentation/pages/post_form_screen.dart';
import 'package:lionsns/features/feed/presentation/pages/post_detail_screen.dart';
import 'package:lionsns/features/feed/presentation/pages/liked_posts_screen.dart';
import 'package:lionsns/presentation/pages/main_navigation_screen.dart';


class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String postCreate = '/post/create';
  static const String likedPosts = '/liked-posts';
  static const String notificationSettings = '/settings/notifications';
  static String postDetail(String id) => '/post/$id';
  static String userProfile(String userId) => '/user/$userId';
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(isLoggedInProvider);

  final initialDeepLink = DeepLinkService.getInitialDeepLink();
  final safeInitialLocation = (initialDeepLink != null && initialDeepLink != '/CALLBACK') 
      ? initialDeepLink 
      : AppRoutes.home;
  
  final initialLocation = safeInitialLocation;

  final router = GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final uri = state.uri;
      debugPrint('[Router] redirect 호출 - currentPath: $currentPath, fullUri: $uri');
      
      // 네이버 로그인 콜백 처리
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final userId = uri.queryParameters['user_id'];
      final success = uri.queryParameters['success'];
      
      debugPrint('[Router] 네이버 로그인 콜백 파라미터 확인 - success: $success, userId: $userId, accessToken: ${accessToken != null ? "있음" : "없음"}, refreshToken: ${refreshToken != null ? "있음" : "없음"}');
      
      if (success == 'true' && userId != null) {
        debugPrint('[Router] 네이버 로그인 콜백 감지 - userId: $userId');
        
        // access_token이 있으면 세션 복원
        if (accessToken != null) {
          debugPrint('[Router] access_token으로 세션 복원 시작');
          SupabaseService.client.auth.setSession(accessToken).then((response) {
            debugPrint('[Router] 세션 복원 완료 - user: ${response.user?.id ?? "null"}');
            // 세션 복원 후 사용자 정보 새로고침
            ref.read(authViewModelProvider.notifier).refresh();
          }).catchError((error) {
            debugPrint('[Router] 세션 복원 실패: $error');
            // 세션 복원 실패 시에도 사용자 정보 새로고침 시도
            ref.read(authViewModelProvider.notifier).refresh();
          });
        } else {
          debugPrint('[Router] access_token이 없음 - 세션 복원 불가');
          debugPrint('[Router] 참고: Edge Function에서 사용자를 생성했지만 세션이 앱에 복원되지 않았습니다.');
          debugPrint('[Router] Supabase Admin API는 직접 세션 토큰을 생성하는 메서드를 제공하지 않습니다.');
          debugPrint('[Router] 사용자 정보 새로고침만 수행합니다.');
          
          // access_token이 없으면 사용자 정보 새로고침만 수행
          // (세션이 없어서 실제로는 작동하지 않을 수 있음)
          Future.delayed(const Duration(milliseconds: 500), () {
            debugPrint('[Router] 사용자 정보 새로고침 시도');
            ref.read(authViewModelProvider.notifier).refresh();
          });
        }
        
        // 세션 복원 중이므로 홈으로 리다이렉트
        return AppRoutes.home;
      }
      
      final isGoingToLogin = currentPath == AppRoutes.login;
      final isGoingToProfile = currentPath == AppRoutes.profile || currentPath == AppRoutes.profileEdit;
      final isGoingToPostDetail = currentPath.startsWith('/post/');
      
      if (currentPath == '/CALLBACK') {
        debugPrint('[Router] CALLBACK 경로 감지 - 홈으로 리다이렉트');
        return AppRoutes.home;
      }
      
      if (isGoingToProfile) {
        debugPrint('[Router] 프로필 화면으로 이동 - 리다이렉트 없음');
        return null;
      }
      
      if (isGoingToPostDetail) {
        debugPrint('[Router] 게시글 상세 화면으로 이동 - 리다이렉트 없음');
        return null;
      }
      
      final authResult = ref.read(authViewModelProvider);
      debugPrint('[Router] authResult 상태: ${authResult.runtimeType}');
      
      if (authResult is Pending) {
        debugPrint('[Router] 인증 진행 중 - 리다이렉트 없음');
        return null;
      }
      
      final isAuthenticated = authResult.when(
        success: (user) {
          final authenticated = user != null;
          debugPrint('[Router] 인증 상태 확인 - authenticated: $authenticated, userId: ${user?.id ?? "null"}');
          return authenticated;
        },
        failure: (_, __) {
          debugPrint('[Router] 인증 실패 - authenticated: false');
          return false;
        },
        pending: (_) {
          debugPrint('[Router] 인증 진행 중 - authenticated: false');
          return false;
        },
      );

      if (!isAuthenticated && !isGoingToLogin) {
        debugPrint('[Router] 미인증 상태 - 로그인 화면으로 리다이렉트');
        return AppRoutes.login;
      }

      if (isAuthenticated && isGoingToLogin) {
        debugPrint('[Router] 이미 인증됨 - 홈으로 리다이렉트');
        return AppRoutes.home;
      }

      debugPrint('[Router] 리다이렉트 없음 - 계속 진행');
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profileEdit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.postCreate,
        name: 'postCreate',
        builder: (context, state) {
          final postId = state.uri.queryParameters['postId'];
          return PostFormScreen(postId: postId);
        },
      ),
      GoRoute(
        path: AppRoutes.likedPosts,
        name: 'likedPosts',
        builder: (context, state) => const LikedPostsScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        name: 'postDetail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        body: Center(
          child: Text(l10n?.pageNotFound(state.uri.toString()) ?? '페이지를 찾을 수 없습니다: ${state.uri}'),
        ),
      );
    },
  );
  
  DeepLinkService.initialize(router);
  
  return router;
});
