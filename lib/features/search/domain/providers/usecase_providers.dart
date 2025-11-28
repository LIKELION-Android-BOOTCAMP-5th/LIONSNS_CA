import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/features/search/domain/usecases/search_usecase.dart';
import 'repository_providers.dart';

final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  return SearchUseCase(factory);
});

