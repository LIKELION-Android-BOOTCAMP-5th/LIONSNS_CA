import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lionsns/l10n/app_localizations.dart';
import 'package:lionsns/config/router.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/feed/presentation/providers/providers.dart';
import 'package:lionsns/features/auth/presentation/providers/providers.dart';
import '../widgets/post_card.dart';

/// 게시글 리스트 화면
class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsResult = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postListTitle),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push(AppRoutes.likedPosts),
            tooltip: l10n.likedPosts,
          ),
        ],
      ),
      body: postsResult.when(
        success: (posts) {
          // 로딩 완료 후 게시글이 정말 없을 때만 빈 상태 메시지 표시
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.postEmpty,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.postEmptyHint,
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
              ref.read(postListProvider.notifier).loadPosts();
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
                    // 삭제 확인 다이얼로그는 PostCard에서 처리
                    await ref.read(postListProvider.notifier).deletePost(post.id);
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
                  l10n.postError,
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
                    ref.read(postListProvider.notifier).loadPosts();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          );
        },
        pending: (_) {
          // 로딩 중에는 로딩 인디케이터 표시
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.postLoading,
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

