import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/core/services/internal/widget_update_service_provider.dart';
import 'package:lionsns/core/services/internal/storage_service_provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_edit_viewmodel.dart';
import '../viewmodels/follow_viewmodel.dart';
import '../../domain/providers/usecase_providers.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, Result<User?>>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final watchAuthStateUseCase = ref.watch(watchAuthStateUseCaseProvider);
  final widgetUpdateService = ref.watch(widgetUpdateServiceProvider);
  return AuthViewModel(
    signInUseCase: signInUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    logoutUseCase: logoutUseCase,
    watchAuthStateUseCase: watchAuthStateUseCase,
    widgetUpdateService: widgetUpdateService,
  );
});

/// 현재 로그인 상태를 boolean으로 제공
final isLoggedInProvider = Provider<bool>((ref) {
  final authResult = ref.watch(authViewModelProvider);
  return authResult.when(
    success: (user) => user != null,
    failure: (_, __) => false,
    pending: (_) => false,
  );
});

/// Auth Provider (하위 호환성을 위한 별칭)
final authProvider = authViewModelProvider;

/// autoDispose: 화면을 벗어나면 자동으로 dispose되어 메모리 효율성 향상
final profileEditViewModelProvider = StateNotifierProvider.autoDispose<ProfileEditViewModel, ProfileEditState>((ref) {
  final getProfileUseCase = ref.watch(getProfileUseCaseProvider);
  final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ProfileEditViewModel(
    getProfileUseCase: getProfileUseCase,
    updateProfileUseCase: updateProfileUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    storageService: storageService,
  );
});

/// autoDispose: 위젯이 dispose되면 자동으로 dispose되어 메모리 효율성 향상
final followViewModelProvider = StateNotifierProvider.autoDispose.family<FollowViewModel, FollowState, String>((ref, userId) {
  final toggleFollowUseCase = ref.watch(toggleFollowUseCaseProvider);
  final getFollowStatusUseCase = ref.watch(getFollowStatusUseCaseProvider);
  final currentUser = ref.watch(authViewModelProvider).when(
        success: (user) => user?.id,
        failure: (_, __) => null,
        pending: (_) => null,
      );
  return FollowViewModel(
    toggleFollowUseCase: toggleFollowUseCase,
    getFollowStatusUseCase: getFollowStatusUseCase,
    targetUserId: userId,
    currentUserId: currentUser,
  );
});
