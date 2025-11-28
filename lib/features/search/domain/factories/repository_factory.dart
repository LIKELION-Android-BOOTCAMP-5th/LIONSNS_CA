import 'package:lionsns/features/search/domain/repositories/search_repository.dart';

/// Domain 레이어가 Data 레이어를 직접 import하지 않도록 하는 인터페이스
abstract class RepositoryFactory {
  /// SearchRepository 생성
  SearchRepository createSearchRepository();
}

