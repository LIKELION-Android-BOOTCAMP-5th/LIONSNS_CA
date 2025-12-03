import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/feed/domain/usecases/get_posts_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_post_by_id_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/create_post_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/update_post_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/delete_post_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_comments_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/create_comment_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_like_count_usecase.dart';
import 'package:lionsns/features/feed/domain/usecases/get_user_liked_posts_usecase.dart';
import 'package:lionsns/features/auth/domain/providers/usecase_providers.dart';
import '../../data/providers/factory_providers.dart';

final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  return GetPostsUseCase(repository);
});

final getPostByIdUseCaseProvider = Provider<GetPostByIdUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  return GetPostByIdUseCase(repository);
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return CreatePostUseCase(repository, getCurrentUserUseCase);
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final getPostByIdUseCase = ref.watch(getPostByIdUseCaseProvider);
  return UpdatePostUseCase(repository, getCurrentUserUseCase, getPostByIdUseCase);
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final getPostByIdUseCase = ref.watch(getPostByIdUseCaseProvider);
  return DeletePostUseCase(repository, getCurrentUserUseCase, getPostByIdUseCase);
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createCommentRepository();
  return GetCommentsUseCase(repository);
});

final createCommentUseCaseProvider = Provider<CreateCommentUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createCommentRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return CreateCommentUseCase(repository, getCurrentUserUseCase);
});

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createLikeRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return ToggleLikeUseCase(repository, getCurrentUserUseCase);
});

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createCommentRepository();
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final getCommentsUseCase = ref.watch(getCommentsUseCaseProvider);
  return DeleteCommentUseCase(repository, getCurrentUserUseCase, getCommentsUseCase);
});

final getLikeCountUseCaseProvider = Provider<GetLikeCountUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createLikeRepository();
  return GetLikeCountUseCase(repository);
});

final getUserLikedPostsUseCaseProvider = Provider<GetUserLikedPostsUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createPostRepository();
  return GetUserLikedPostsUseCase(repository);
});
