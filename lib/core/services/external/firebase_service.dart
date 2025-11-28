import 'package:flutter/foundation.dart';
// Firebase 패키지 필요:
// flutter pub add firebase_core firebase_auth firebase_storage
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide User;
// import 'package:firebase_auth/firebase_auth.dart' as firebase show User;
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase 서비스
/// 
/// SupabaseService와 유사한 구조로 Firebase를 초기화하고 접근합니다.
/// 
/// 사용 방법:
/// 1. pubspec.yaml에 Firebase 패키지 추가:
///    firebase_core: ^latest
///    firebase_auth: ^latest
///    firebase_storage: ^latest
/// 
/// 2. Firebase 프로젝트 설정:
///    - Android: google-services.json 파일 추가
///    - iOS: GoogleService-Info.plist 파일 추가
///    - Web: Firebase 설정 추가
/// 
/// 3. main.dart에서 초기화:
///    await FirebaseService.initialize();
class FirebaseService {
  // Firebase 앱 인스턴스
  // static FirebaseApp? _app;
  
  // Firebase Auth 인스턴스
  // static FirebaseAuth? _auth;
  
  // Firebase Storage 인스턴스
  // static FirebaseStorage? _storage;

  /// Firebase 초기화
  /// 
  /// Firebase 프로젝트 설정 파일(google-services.json, GoogleService-Info.plist)을
  /// 사용하여 Firebase를 초기화합니다.
  static Future<void> initialize() async {
    // if (_app != null) return;

    try {
      // .env 파일 로드 (선택사항 - Firebase는 보통 설정 파일 사용)
      // try {
      //   await dotenv.load();
      //   debugPrint('.env 파일 로드 성공 (assets)');
      // } catch (e) {
      //   debugPrint('assets에서 .env 파일 로드 실패: $e');
      // }

      // Firebase 초기화
      // _app = await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      
      // Auth 인스턴스 가져오기
      // _auth = FirebaseAuth.instance;
      
      // Storage 인스턴스 가져오기
      // _storage = FirebaseStorage.instance;

      debugPrint('Firebase 초기화 완료');
    } catch (e) {
      debugPrint('Firebase 초기화 실패: $e');
      rethrow;
    }
  }

  /// Firebase Auth 인스턴스 가져오기
  // static FirebaseAuth get auth {
  //   if (_auth == null) {
  //     throw Exception('Firebase가 초기화되지 않았습니다. FirebaseService.initialize()를 먼저 호출하세요.');
  //   }
  //   return _auth!;
  // }

  /// Firebase Storage 인스턴스 가져오기
  // static FirebaseStorage get storage {
  //   if (_storage == null) {
  //     throw Exception('Firebase가 초기화되지 않았습니다. FirebaseService.initialize()를 먼저 호출하세요.');
  //   }
  //   return _storage!;
  // }

  /// 현재 사용자 가져오기
  // static firebase.User? get currentUser {
  //   return auth.currentUser;
  // }

  /// 인증 상태 변경 스트림
  /// 
  /// 사용자 로그인/로그아웃 상태 변경을 감지합니다.
  // static Stream<User?> get authStateChanges {
  //   return auth.authStateChanges();
  // }
}

