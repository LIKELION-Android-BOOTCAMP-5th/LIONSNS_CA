import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/toggle_follow_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_follow_status_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_follow_list_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:lionsns/features/auth/domain/usecases/update_profile_usecase.dart';
import 'repository_providers.dart';

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createAuthRepository();
  return SignInUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createAuthRepository();
  return GetCurrentUserUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createAuthRepository();
  return LogoutUseCase(repository);
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createAuthRepository();
  return WatchAuthStateUseCase(repository);
});

final toggleFollowUseCaseProvider = Provider<ToggleFollowUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createFollowRepository();
  return ToggleFollowUseCase(repository);
});

final getFollowStatusUseCaseProvider = Provider<GetFollowStatusUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createFollowRepository();
  return GetFollowStatusUseCase(repository);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createProfileRepository();
  return GetProfileUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createProfileRepository();
  return UpdateProfileUseCase(repository);
});

final getFollowListUseCaseProvider = Provider<GetFollowListUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createFollowRepository();
  return GetFollowListUseCase(repository);
});

