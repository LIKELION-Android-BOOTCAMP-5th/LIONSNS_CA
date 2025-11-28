import 'dart:async';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/features/auth/domain/repositories/auth_repository.dart' as domain;
import 'package:lionsns/features/auth/domain/repositories/profile_repository.dart';
import 'package:lionsns/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:lionsns/core/services/external/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show AuthChangeEvent;


/// Firebase로 교체할 때는 FirebaseAuthRepository를 만들고 같은 인터페이스를 구현하면 됩니다.
class SupabaseAuthRepository implements domain.AuthRepository {
  final SupabaseAuthDatasource _authDatasource;

  SupabaseAuthRepository({
    required SupabaseAuthDatasource authDatasource,
    required ProfileRepository profileRepository, // 향후 사용 예정
  })  : _authDatasource = authDatasource;

  @override
  Future<Result<User?>> snsLogin(AuthProvider provider) async {
    return await _authDatasource.snsLogin(provider);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return await _authDatasource.getCurrentUser();
  }

  @override
  Future<Result<void>> logout() async {
    return await _authDatasource.logout();
  }

  @override
  String? getCurrentUserId() {
    return _authDatasource.getCurrentUserId();
  }

  @override
  Stream<domain.AuthStateChange> get authStateChanges {
    return SupabaseService.authStateChanges.map((authState) {
      // Supabase의 AuthChangeEvent를 우리 도메인의 AuthChangeEvent로 매핑
      final supabaseEvent = authState.event;
      if (supabaseEvent == supabase.AuthChangeEvent.signedIn) {
        return domain.AuthStateChange(domain.AuthChangeEvent.signedIn);
      } else if (supabaseEvent == supabase.AuthChangeEvent.signedOut) {
        return domain.AuthStateChange(domain.AuthChangeEvent.signedOut);
      } else if (supabaseEvent == supabase.AuthChangeEvent.tokenRefreshed) {
        return domain.AuthStateChange(domain.AuthChangeEvent.tokenRefreshed);
      } else if (supabaseEvent == supabase.AuthChangeEvent.userUpdated) {
        return domain.AuthStateChange(domain.AuthChangeEvent.userUpdated);
      } else {
        // 다른 이벤트는 무시하거나 signedOut으로 처리
        return domain.AuthStateChange(domain.AuthChangeEvent.signedOut);
      }
    });
  }
}

