import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import 'package:url_launcher/url_launcher.dart';
import '../../utils/result.dart';

class AuthProviderService {
  /// Google 소셜 로그인
  /// 
  /// LaunchMode.platformDefault: Android에서 Chrome Custom Tabs 사용
  /// 로그인 완료 후 deep link로 돌아올 때 브라우저가 자동으로 닫힘
  static Future<Result<AuthResponse>> loginWithGoogle() async {
    try {
      final redirectUrl = dotenv.env['REDIRECT_URL'];
      if (redirectUrl == null) {
        throw Exception('Redirect URL이 설정되지 않았습니다. .env 파일을 확인하세요.');
      }
      
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      return Pending('OAuth 로그인이 진행중입니다.브라우저에서 로그인을 완료해주세요!');
    } catch (e) {
      return Failure('Google 로그인에 실패했습니다 : $e');
    }
  }

  /// Apple 소셜 로그인
  static Future<Result<AuthResponse>> loginWithApple() async {
    return Pending('OAuth 로그인이 진행중입니다.브라우저에서 로그인을 완료해주세요!');
  }

  /// Kakao 소셜 로그인
  static Future<Result<AuthResponse>> loginWithKakao() async {
    return Pending('OAuth 로그인이 진행중입니다.브라우저에서 로그인을 완료해주세요!');
  }

  /// Naver 소셜 로그인
  /// 
  /// Supabase Edge Function을 통해 네이버 OAuth를 처리합니다.
  /// 네이버 OAuth flow:
  /// 1. 네이버 인증 페이지로 이동
  /// 2. 사용자 인증 후 Edge Function으로 callback
  /// 3. Edge Function에서 네이버 API로 사용자 정보 가져오기
  /// 4. Supabase에 사용자 생성/로그인
  /// 5. 앱으로 리다이렉트
  static Future<Result<AuthResponse>> loginWithNaver() async {
    try {
      final redirectUrl = dotenv.env['REDIRECT_URL'];
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final naverClientId = dotenv.env['NAVER_CLIENT_ID'];
      
      if (redirectUrl == null || supabaseUrl == null || naverClientId == null) {
        throw Exception('환경 변수가 설정되지 않았습니다. .env 파일을 확인하세요. (REDIRECT_URL, SUPABASE_URL, NAVER_CLIENT_ID)');
      }

      // 보안을 위한 state 값 생성
      final random = Random.secure();
      final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final state = List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();

      // Edge Function callback URL
      final callbackUrl = '$supabaseUrl/functions/v1/naver-auth-callback?redirect_to=$redirectUrl';

      // 네이버 OAuth 인증 URL 생성
      final authUrl = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
        'response_type': 'code',
        'client_id': naverClientId,
        'redirect_uri': callbackUrl,
        'state': state,
      });

      // 외부 브라우저로 네이버 인증 페이지 열기
      // 주의: Android에서 canLaunchUrl이 HTTPS URL에 대해 false를 반환할 수 있으므로
      // 체크를 건너뛰고 바로 launchUrl을 호출합니다.
      final uri = Uri.parse(authUrl.toString());
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return Pending('OAuth 로그인이 진행중입니다. 브라우저에서 로그인을 완료해주세요!');
      } catch (e) {
        // launchUrl 실패 시 예외 처리
        throw Exception('URL을 열 수 없습니다: $authUrl. 오류: $e');
      }
    } catch (e) {
      return Failure('네이버 로그인에 실패했습니다: $e');
    }
  }

  /// AuthResponse를 User 모델로 변환
  /// 
  /// 사용자 이름 우선순위: full_name > name > email의 @ 앞부분 > '사용자'
  static User authResponseToUser(AuthResponse authResponse) {
    final user = authResponse.user;
    if(user == null) {
      throw Exception('사용자 정보가 없습니다.');
    }
    final userMetadata = user.userMetadata ?? {};
    return User(
      id: user.id,
      name: userMetadata['full_name'] as String? ??
        userMetadata['name'] as String? ??
          (user.email?.split('@')[0] ?? '사용자'),
      email: user.email ?? '',
      profileImageUrl: userMetadata['avatar_url'] as String?,
      provider: _getProviderFromSupabaseUser(user),
      createdAt: DateTime.parse(user.createdAt)
    );
  }

  static AuthProvider _getProviderFromSupabaseUser(supabase.User supabaseUser) {
    final appMetadata = supabaseUser.appMetadata;
    final provider = appMetadata['provider'] as String? ?? 'email';

    switch (provider) {
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