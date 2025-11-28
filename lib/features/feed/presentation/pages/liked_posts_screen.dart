import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/config/router.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/l10n/app_localizations.dart';
import 'package:lionsns/features/feed/presentation/providers/providers.dart';
import 'package:lionsns/features/auth/presentation/providers/providers.dart';
import '../widgets/post_card.dart';

/// 좋아요한 게시글 리스트 화면
class LikedPostsScreen extends ConsumerWidget {
  const LikedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final likedPostsResult = ref.watch(likedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.likedPosts),
        elevation: 1,
      ),
      body: likedPostsResult.when(
        success: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.likedPostsEmpty,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.likedPostsEmptyHint,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(likedPostsProvider.notifier).loadLikedPosts();
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final currentUserId = ref.read(authViewModelProvider).when(
                  success: (user) => user?.id,
                  failure: (_, __) => null,
                  pending: (_) => null,
                );
                final isAuthor = post.authorId == currentUserId;

                return PostCard(
                  post: post,
                  onTap: () => context.push(AppRoutes.postDetail(post.id)),
                  onDelete: isAuthor ? () async {
                    await ref.read(postListProvider.notifier).deletePost(post.id);
                    // 삭제 후 좋아요 목록 새로고침
                    ref.read(likedPostsProvider.notifier).loadLikedPosts();
                  } : null,
                );
              },
            ),
          );
        },
        failure: (message, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.error,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(likedPostsProvider.notifier).loadLikedPosts();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          );
        },
        pending: (_) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.likedPostsLoading,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

