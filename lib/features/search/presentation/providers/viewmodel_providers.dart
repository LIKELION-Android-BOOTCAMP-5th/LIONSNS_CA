import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lionsns/core/utils/result.dart';
import 'package:lionsns/features/search/domain/entities/search_results.dart';
import 'package:lionsns/features/search/presentation/viewmodels/search_viewmodel.dart';
import '../../domain/providers/usecase_providers.dart';

final searchViewModelProvider = StateNotifierProvider.autoDispose<SearchViewModel, Result<SearchResults>>((ref) {
  final searchUseCase = ref.watch(searchUseCaseProvider);
  return SearchViewModel(searchUseCase: searchUseCase);
});

/// 하위 호환성을 위한 별칭
final searchProvider = searchViewModelProvider;

