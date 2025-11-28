import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/l10n/app_localizations.dart';
import 'package:lionsns/config/router.dart';
import 'package:lionsns/features/auth/domain/entities/user.dart';
import 'package:lionsns/core/utils/result.dart';
import '../providers/providers.dart';
import '../viewmodels/follow_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;
  
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isViewingOtherUser = userId != null;
    
    if (isViewingOtherUser) {
      return _buildOtherUserProfile(context, ref, userId!);
    } else {
      return _buildCurrentUserProfile(context, ref);
    }
  }

  Widget _buildCurrentUserProfile(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('[ProfileScreen] 현재 사용자 프로필 화면 빌드 시작');
    final authResult = ref.watch(authViewModelProvider);
    
    debugPrint('[ProfileScreen] authResult 상태: ${authResult.runtimeType}');
    authResult.when(
      success: (user) => debugPrint('[ProfileScreen] 사용자 정보: ${user?.id ?? "null"}, 이름: ${user?.name ?? "null"}'),
      failure: (message, error) => debugPrint('[ProfileScreen] 오류: $message, $error'),
      pending: (message) => debugPrint('[ProfileScreen] 로딩 중: $message'),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profile),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(AppRoutes.profileEdit),
            ),
          ],
        ),
        body: authResult.when(
          success: (user) {
            debugPrint('[ProfileScreen] success 상태 - user: ${user?.id ?? "null"}');
            if (user == null) {
              debugPrint('[ProfileScreen] 사용자가 null - 로그인 필요 메시지 표시');
              return Center(
                child: Text(l10n.loginRequired),
              );
            }

            debugPrint('[ProfileScreen] 팔로우 상태 조회 시작 - userId: ${user.id}');
            final followState = ref.watch(followViewModelProvider(user.id));
            debugPrint('[ProfileScreen] 팔로우 상태 조회 완료');

            return _buildProfileContent(context, ref, user, followState, true);
          },
          failure: (message, error) {
            debugPrint('[ProfileScreen] failure 상태 - message: $message, error: $error');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('[ProfileScreen] 다시 시도 버튼 클릭');
                      ref.invalidate(authViewModelProvider);
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          },
          pending: (message) {
            debugPrint('[ProfileScreen] pending 상태 - message: $message');
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildOtherUserProfile(BuildContext context, WidgetRef ref, String targetUserId) {
    final l10n = AppLocalizations.of(context)!;
    final getProfileUseCase = ref.read(getProfileUseCaseProvider);
    final profileFuture = getProfileUseCase(targetUserId);
    final followState = ref.watch(followViewModelProvider(targetUserId));
    
    final authResult = ref.watch(authViewModelProvider);
    final currentUser = authResult.when(
      success: (user) => user,
      failure: (_, __) => null,
      pending: (_) => null,
    );
    final isCurrentUser = currentUser?.id == targetUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: FutureBuilder<Result<User?>>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.profileLoadError,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.goBack),
                  ),
                ],
              ),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return Center(child: Text(l10n.dataLoadError));
          }

          return result.when(
            success: (user) {
              if (user == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.profileNotFound,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.goBack),
                      ),
                    ],
                  ),
                );
              }

              return _buildOtherUserProfileContent(context, ref, user, followState);
            },
            failure: (message, error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.goBack),
                    ),
                  ],
                ),
              );
            },
            pending: (_) => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildOtherUserProfileContent(
    BuildContext context,
    WidgetRef ref,
    User user,
    FollowState followState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final authResult = ref.watch(authViewModelProvider);
    final currentUser = authResult.when(
      success: (user) => user,
      failure: (_, __) => null,
      pending: (_) => null,
    );
    final currentUserId = currentUser?.id;
    final isCurrentUser = currentUserId == user.id;
    final canFollow = !isCurrentUser && currentUserId != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Center(
          child: _buildProfileAvatar(
            context,
            imageUrl: user.profileImageUrl,
            radius: 60,
            fallbackText: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 32),
        _buildFollowStats(context, ref, user.id, followState),
        const SizedBox(height: 32),
        if (canFollow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: followState.isLoading
                  ? null
                  : () async {
                      final viewModel = ref.read(followViewModelProvider(user.id).notifier);
                      await viewModel.toggleFollow();
                      
                      final authResult = ref.read(authViewModelProvider);
                      final currentUser = authResult.when(
                        success: (user) => user,
                        failure: (_, __) => null,
                        pending: (_) => null,
                      );
                      if (currentUser != null) {
                        ref.invalidate(followViewModelProvider(currentUser.id));
                      }
                    },
              icon: Icon(
                followState.isFollowingResult.when(
                  success: (isFollowing) => isFollowing
                      ? Icons.person_remove
                      : Icons.person_add,
                  failure: (_, __) => Icons.person_add,
                  pending: (_) => Icons.person_add,
                ),
              ),
              label: Text(
                followState.isFollowingResult.when(
                  success: (isFollowing) => isFollowing ? l10n.unfollow : l10n.follow,
                  failure: (_, __) => l10n.follow,
                  pending: (_) => l10n.loading,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: followState.isFollowingResult.when(
                  success: (isFollowing) => isFollowing
                      ? Colors.grey[300]
                      : Theme.of(context).primaryColor,
                  failure: (_, __) => Theme.of(context).primaryColor,
                  pending: (_) => Theme.of(context).primaryColor,
                ),
                foregroundColor: followState.isFollowingResult.when(
                  success: (isFollowing) => isFollowing
                      ? Colors.black87
                      : Colors.white,
                  failure: (_, __) => Colors.white,
                  pending: (_) => Colors.white,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    User user,
    FollowState followState,
    bool isCurrentUser,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Center(
          child: _buildProfileAvatar(
            context,
            imageUrl: user.profileImageUrl,
            radius: 60,
            fallbackText: user.name[0].toUpperCase(),
          ),
        ),

        const SizedBox(height: 24),
        _buildFollowStats(context, ref, user.id, followState),
        const SizedBox(height: 24),
        _buildInfoCard(
          context,
          Icons.person,
          l10n.name,
          user.name,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          Icons.email,
          l10n.email,
          user.email,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          Icons.login,
          l10n.loginMethod,
          _getProviderName(user.provider, context),
        ),
        const SizedBox(height: 32),
        if (isCurrentUser)
          ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getProviderName(AuthProvider provider, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.kakao:
        return l10n?.kakaoLogin ?? 'Kakao';
      case AuthProvider.naver:
        return l10n?.naverLogin ?? 'Naver';
    }
  }

  Widget _buildProfileAvatar(
    BuildContext context, {
    required String? imageUrl,
    required double radius,
    required String fallbackText,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Text(
          fallbackText,
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 디폴트 아이콘
                  Center(
                    child: Icon(
                      Icons.person_outline,
                      size: radius * 1.2,
                      color: Colors.grey[400],
                    ),
                  ),
                  // 로딩 인디케이터
                  Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ],
              ),
            );
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  fallbackText,
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowStats(
    BuildContext context,
    WidgetRef ref,
    String userId,
    FollowState followState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFollowStatItem(
              context,
              ref,
              l10n.follower,
              followState.followerCountResult.when(
                success: (count) => count.toString(),
                failure: (_, __) => '0',
                pending: (_) => '-',
              ),
              () {
                _showFollowListDialog(context, ref, userId, true);
              },
            ),
            const VerticalDivider(),
            _buildFollowStatItem(
              context,
              ref,
              l10n.following,
              followState.followingCountResult.when(
                success: (count) => count.toString(),
                failure: (_, __) => '0',
                pending: (_) => '-',
              ),
              () {
                _showFollowListDialog(context, ref, userId, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowStatItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowListDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
    bool isFollowers,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFollowers ? l10n.follower : l10n.following),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _buildFollowList(context, ref, userId, isFollowers),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowList(
    BuildContext context,
    WidgetRef ref,
    String userId,
    bool isFollowers,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final getFollowListUseCase = ref.read(getFollowListUseCaseProvider);
    final future = isFollowers
        ? getFollowListUseCase.getFollowers(userId)
        : getFollowListUseCase.getFollowing(userId);

    return FutureBuilder<Result<List<User>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.errorOccurred(snapshot.error.toString()),
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        }

        final result = snapshot.data;
        if (result == null) {
          return Center(child: Text(l10n.dataLoadError));
        }

        return result.when(
          success: (users) {
            if (users.isEmpty) {
              return Center(
                child: Text(
                  isFollowers ? l10n.followersEmpty : l10n.followingEmpty,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            final authResult = ref.read(authViewModelProvider);
            final currentUser = authResult.when(
              success: (user) => user,
              failure: (_, __) => null,
              pending: (_) => null,
            );
            final currentUserId = currentUser?.id;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isCurrentUser = currentUserId == user.id;
                final canFollow = !isCurrentUser && currentUserId != null;
                
                final followState = canFollow
                    ? ref.watch(followViewModelProvider(user.id))
                    : null;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null ||
                            user.profileImageUrl!.isEmpty
                        ? Text(user.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: user.email.isNotEmpty ? Text(user.email) : null,
                  trailing: canFollow && followState != null
                      ? _buildFollowButton(context, ref, user.id, followState)
                      : null,
                );
              },
            );
          },
          failure: (message, error) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Text(
                l10n.errorOccurred(message),
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          },
          pending: (_) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildFollowButton(
    BuildContext context,
    WidgetRef ref,
    String targetUserId,
    FollowState followState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isFollowing = followState.isFollowingResult.when(
      success: (value) => value,
      failure: (_, __) => false,
      pending: (_) => false,
    );

    return followState.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : TextButton(
            onPressed: () async {
              final viewModel = ref.read(followViewModelProvider(targetUserId).notifier);
              await viewModel.toggleFollow();
              
              final authResult = ref.read(authViewModelProvider);
              final currentUser = authResult.when(
                success: (user) => user,
                failure: (_, __) => null,
                pending: (_) => null,
              );
              if (currentUser != null) {
                ref.invalidate(followViewModelProvider(currentUser.id));
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(80, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isFollowing ? l10n.unfollow : l10n.follow,
              style: TextStyle(
                fontSize: 12,
                color: isFollowing ? Colors.grey[700] : Theme.of(context).primaryColor,
              ),
            ),
          );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

