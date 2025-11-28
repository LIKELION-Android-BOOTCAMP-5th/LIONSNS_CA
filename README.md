# Lion SNS

소셜 네트워크 서비스(SNS) Flutter 애플리케이션 - Clean Architecture 완전 적용

## 프로젝트 소개

Lion SNS는 Flutter로 개발된 소셜 네트워크 서비스 애플리케이션입니다. 사용자들이 게시글을 작성하고, 서로 소통하며, 팔로우할 수 있는 기능을 제공합니다.

이 프로젝트는 **Clean Architecture**를 완전히 적용하여, 확장 가능하고 유지보수가 용이한 코드 구조를 목표로 합니다. 대규모 프로젝트에서 요구되는 복잡한 비즈니스 로직을 체계적으로 관리하고, 백엔드 독립적인 도메인 로직을 구현합니다.

**아키텍처**: Clean Architecture + MVVM + Feature-Based

## 주요 기능

### 인증 및 프로필
- **소셜 로그인**: Google, Apple, Kakao, Naver 소셜 로그인 지원
- **프로필 관리**: 프로필 정보 조회, 편집
- **프로필 이미지**: 프로필 이미지 업로드 및 변경
- **팔로우/언팔로우**: 사용자 팔로우 및 언팔로우 기능

### 게시글
- **게시글 작성/수정/삭제**: 텍스트 및 이미지가 포함된 게시글 작성
- **게시글 목록**: 모든 게시글 목록 조회 (작성자 정보 포함)
- **게시글 상세**: 게시글 상세 정보 조회
- **이미지 업로드**: 게시글에 이미지 첨부 기능
- **내가 좋아요한 게시글**: 좋아요한 게시글 모아보기

### 댓글
- **댓글 작성**: 게시글에 댓글 작성
- **댓글 조회**: 게시글별 댓글 목록 조회
- **작성자 정보**: 댓글 작성자 프로필 정보 표시

### 좋아요
- **좋아요/좋아요 취소**: 게시글 좋아요 기능
- **좋아요 개수**: 게시글별 좋아요 개수 표시

### 검색
- **게시글 검색**: 게시글 내용 검색
- **사용자 검색**: 사용자 이름 검색
- **댓글 검색**: 댓글 내용 검색

### 홈 화면 위젯
- **통계 정보**: 총 게시글 수, 좋아요 수, 댓글 수 표시
- **최근 게시물**: 가장 최근에 작성한 게시물 정보 표시
- **바로가기**: 위젯에서 앱 실행 및 게시물 상세 화면 이동
- **로그인 상태**: 비로그인 시 로그인 버튼 표시

### 푸시 알림
- **Firebase Cloud Messaging**: 댓글, 좋아요 등 알림 수신

### 다국어 지원
- **한국어/영어**: 앱 전체 다국어 지원 (i18n)

## 기술 스택

### 프론트엔드
- **Flutter**: 크로스 플랫폼 모바일 앱 개발 프레임워크
- **Riverpod**: 상태 관리 및 의존성 주입 (Provider 기반)
- **GoRouter**: 선언적 라우팅 및 Deep Link 지원

### 백엔드
- **Supabase**: 백엔드 서비스 (인증, 데이터베이스, Storage)
- **PostgreSQL**: 관계형 데이터베이스
- **Supabase Storage**: 이미지 및 파일 저장

### 인증
- **Supabase Auth**: OAuth 및 소셜 로그인 지원
- **소셜 로그인**: Google, Apple, Kakao, Naver

### 푸시 알림
- **Firebase Cloud Messaging**: 푸시 알림 서비스
- **Supabase Edge Functions**: 알림 전송 로직

### 위젯
- **Android**: Jetpack Compose Glance 1.1.1
- **iOS**: WidgetKit (SwiftUI)

### 개발 도구
- **build_runner**: 코드 생성 도구
- **json_serializable**: JSON 직렬화/역직렬화

## 프로젝트 구조

### 전체 구조

```
lib/
├── main.dart                    # 앱 진입점
├── config/                      # 앱 설정
│   └── router.dart              # GoRouter 라우팅 설정
│
├── core/                        # 공통 모듈
│   ├── constants/               # 상수 정의
│   │   └── widget_data_keys.dart
│   ├── services/                # 서비스 레이어
│   │   ├── external/            # 외부 서비스 (Supabase, Firebase)
│   │   └── internal/            # 내부 서비스
│   │       ├── widget_data_service.dart
│   │       ├── widget_update_service.dart
│   │       └── deep_link_service.dart
│   ├── utils/                   # 유틸리티
│   │   └── result.dart          # Result 패턴
│   └── widgets/                 # 공통 위젯
│
└── features/                    # 기능별 모듈 (Feature-Based)
    ├── auth/                    # 인증 기능
    │   ├── domain/              # Domain Layer
    │   │   ├── user.dart        # User Entity (순수 객체)
    │   │   ├── usecases/        # Use Cases
    │   │   │   ├── sign_in_usecase.dart
    │   │   │   ├── get_current_user_usecase.dart
    │   │   │   ├── logout_usecase.dart
    │   │   │   ├── watch_auth_state_usecase.dart
    │   │   │   ├── get_profile_usecase.dart
    │   │   │   ├── update_profile_usecase.dart
    │   │   │   ├── toggle_follow_usecase.dart
    │   │   │   └── ...
    │   │   └── repositories/    # Repository 인터페이스
    │   │       ├── auth_repository.dart
    │   │       ├── profile_repository.dart
    │   │       └── follow_repository.dart
    │   ├── data/                # Data Layer
    │   │   ├── dtos/            # DTOs (JSON 직렬화 포함)
    │   │   │   └── user_dto.dart
    │   │   ├── datasources/     # Data Sources
    │   │   │   ├── supabase_auth_datasource.dart
    │   │   │   ├── supabase_profile_datasource.dart
    │   │   │   └── supabase_follow_datasource.dart
    │   │   └── repositories/    # Repository 구현체
    │   │       ├── supabase_auth_repository.dart
    │   │       ├── supabase_profile_repository.dart
    │   │       └── supabase_follow_repository.dart
    │   └── presentation/        # Presentation Layer
    │       ├── providers/       # Provider 정의
    │       ├── viewmodels/      # ViewModel (Use Cases 사용)
    │       ├── pages/           # 화면
    │       └── widgets/         # Feature 전용 위젯
    │
    ├── feed/                    # 피드 기능
    │   ├── domain/              # Domain Layer
    │   │   ├── post.dart        # Post Entity
    │   │   ├── comment.dart     # Comment Entity
    │   │   ├── usecases/        # Use Cases
    │   │   └── repositories/    # Repository 인터페이스
    │   ├── data/                # Data Layer
    │   │   ├── dtos/            # DTOs
    │   │   ├── datasources/     # Data Sources
    │   │   └── repositories/    # Repository 구현체
    │   └── presentation/        # Presentation Layer
    │
    ├── navigation/              # 네비게이션
    └── search/                  # 검색 기능
```

### Feature 구조 예시 (auth)

각 Feature는 다음 3개 레이어로 구성됩니다:

```
features/auth/
├── domain/                      # Domain Layer (비즈니스 로직)
│   ├── user.dart                # Entity (순수 객체, 외부 의존성 없음)
│   ├── usecases/                # Use Cases (비즈니스 로직 캡슐화)
│   │   ├── sign_in_usecase.dart
│   │   ├── get_current_user_usecase.dart
│   │   └── ...
│   └── repositories/            # Repository 인터페이스 (추상화)
│       ├── auth_repository.dart
│       └── profile_repository.dart
│
├── data/                        # Data Layer (구현)
│   ├── dtos/                    # DTOs (JSON 직렬화)
│   │   └── user_dto.dart
│   ├── datasources/             # Data Sources (Supabase 구현)
│   │   └── supabase_auth_datasource.dart
│   └── repositories/            # Repository 구현체
│       └── supabase_auth_repository.dart
│
└── presentation/                # Presentation Layer (UI)
    ├── providers/               # Riverpod Providers
    ├── viewmodels/              # ViewModels
    ├── pages/                   # Screens
    └── widgets/                 # Widgets
```

## 시작하기

### 사전 요구사항

- **Flutter SDK**: 3.9.2 이상
- **Dart SDK**: Flutter와 함께 설치됨
- **Android Studio**: Android 개발 (또는 VS Code + 플러그인)
- **Xcode**: iOS 개발 (macOS만)
- **Supabase 계정**: 백엔드 서비스
- **Firebase 계정**: 푸시 알림 사용 시 (선택사항)

### 설치 및 실행

#### 1. 저장소 클론

```bash
git clone [repository-url]
cd LionSNS-CA
```

#### 2. 의존성 설치

```bash
flutter pub get
```

#### 3. 환경 변수 설정

프로젝트 루트에 `.env` 파일 생성:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

#### 4. 데이터베이스 설정

Supabase 프로젝트 생성 및 데이터베이스 스키마 설정:

1. `docs/설정/Supabase_초기_설정_가이드.md` 참고하여 Supabase 프로젝트 생성
2. `docs/개발/데이터베이스/초기_설정_가이드.md` 참고하여 스키마 생성
3. `docs/설정/Storage/초기_설정_가이드.md` 참고하여 Storage 버킷 설정

#### 5. 코드 생성 (JSON 직렬화)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 6. 앱 실행

```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### 추가 설정 (선택사항)

- **소셜 로그인**: `docs/설정/소셜_로그인_완전_가이드.md` 참고
- **푸시 알림**: `docs/설정/푸시_알림_완전_가이드.md` 참고
- **홈 화면 위젯**: `docs/설정/위젯_구현_가이드.md` 참고

## 아키텍처

### Clean Architecture 개요

이 프로젝트는 **Clean Architecture**를 완전히 적용합니다. Clean Architecture는 비즈니스 로직을 독립적으로 유지하고, 외부 프레임워크나 데이터베이스에 의존하지 않도록 설계된 아키텍처 패턴입니다.

### Riverpod 상태 관리

이 프로젝트는 **Riverpod**을 상태 관리 및 의존성 주입에 사용합니다.

#### 주요 개념

1. **Provider**: 의존성 주입 및 상태 제공
   - `Provider<T>`: 단순 값 제공 (UseCase, Repository 등)
   - `StateNotifierProvider`: 상태 관리용 (ViewModel)

2. **StateNotifier**: 상태 변경 로직 캡슐화
   - ViewModel이 `StateNotifier`를 상속하여 상태 관리
   - UseCase를 통해 비즈니스 로직 실행

3. **ConsumerWidget**: Provider를 사용하는 위젯
   - `ref.watch()`: 상태 감시 및 자동 리빌드
   - `ref.read()`: 상태 읽기 (일회성, 이벤트 처리)

4. **Provider 스코프**:
   - 전역 스코프: 앱 전체 생명주기 (예: 인증 상태)
   - `autoDispose`: 위젯 해제 시 자동 dispose (예: 게시글 목록)
   - `family`: 파라미터별 인스턴스 (예: 게시글 상세, 사용자 프로필)

#### Clean Architecture와의 통합

Riverpod은 Clean Architecture의 의존성 주입을 담당합니다:

```
Presentation Layer (ViewModel)
    ↓ ref.watch()
Domain Layer (UseCase Provider)
    ↓ ref.watch()
Data Layer (Repository Provider)
    ↓ ref.watch()
Core Layer (Service Provider)
```

#### 사용 예제

```dart
// UseCase Provider (Domain Layer)
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final factory = ref.watch(repositoryFactoryProvider);
  final repository = factory.createAuthRepository();
  return SignInUseCase(repository);
});

// ViewModel Provider (Presentation Layer)
final authViewModelProvider = StateNotifierProvider<AuthViewModel, Result<User?>>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  return AuthViewModel(signInUseCase: signInUseCase);
});

// View에서 사용
class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authResult = ref.watch(authViewModelProvider);
    
    return authResult.when(
      success: (user) => user == null ? _buildLoginButtons(ref) : _buildLoggedIn(user),
      failure: (message, _) => _buildError(message),
      pending: (_) => _buildLoading(),
    );
  }
}
```

### 레이어 구조

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  (View → ViewModel → Use Case)              │
└──────────────┬──────────────────────────────┘
               │ 의존
               ▼
┌─────────────────────────────────────────────┐
│            Domain Layer                     │
│  (Use Cases, Entities, Repository 인터페이스) │
│         ← 의존성 역전 원칙 →                 │
└──────────────┬──────────────────────────────┘
               │ 구현
               ▼
┌─────────────────────────────────────────────┐
│             Data Layer                      │
│  (Repository 구현체, DTOs, DataSources)      │
└──────────────┬──────────────────────────────┘
               │ 의존
               ▼
┌─────────────────────────────────────────────┐
│            Core Layer                       │
│  (Services: Supabase, Firebase 등)           │
└─────────────────────────────────────────────┘
```

**데이터 흐름**:
```
View → ViewModel → Use Case → Repository 인터페이스
                              ↓ (구현)
                        Repository 구현체 → Datasource → Service
```

### 각 레이어의 역할

#### 1. Domain Layer (도메인 레이어)

**목적**: 비즈니스 로직의 핵심. 외부 의존성 없이 순수한 비즈니스 규칙을 정의

**구성요소**:
- **Entities**: 순수한 비즈니스 객체 (예: `User`, `Post`, `Comment`)
  - JSON 직렬화 없음
  - 외부 라이브러리 의존성 없음
  - 비즈니스 로직 포함 가능
- **Use Cases**: 단일 책임 비즈니스 로직
  - 하나의 Use Case는 하나의 작업만 수행
  - Repository 인터페이스에만 의존
- **Repository 인터페이스**: 데이터 접근 계약 정의
  - 구체적인 구현 없이 메서드 시그니처만 정의
  - 백엔드 교체 시에도 유지됨

**예시**:
```dart
// Domain Layer - 순수한 Entity
class User {
  final String id;
  final String name;
  final String email;
  // JSON 직렬화 없음, 외부 의존성 없음
}

// Domain Layer - Use Case
class SignInUseCase {
  final AuthRepository _repository;  // 인터페이스에만 의존
  
  Future<Result<User?>> call(AuthProvider provider) {
    return _repository.snsLogin(provider);
  }
}
```

#### 2. Data Layer (데이터 레이어)

**목적**: Domain Layer의 인터페이스를 구현하고, 외부 데이터 소스와 통신

**구성요소**:
- **DTOs**: 데이터 전송 객체 (JSON 직렬화 포함)
  - 외부 API 응답을 받기 위한 객체
  - `@JsonSerializable` 사용
  - Entity로 변환 메서드 제공
- **DataSources**: 특정 백엔드 구현
  - Supabase, Firebase 등의 구체적 구현
  - DTO를 사용하여 데이터 처리
- **Repository 구현체**: Domain의 Repository 인터페이스 구현
  - DataSource를 사용하여 실제 데이터 처리
  - DTO → Entity 변환 수행

**예시**:
```dart
// Data Layer - DTO
@JsonSerializable()
class UserDto {
  final String id;
  final String name;
  
  User toEntity() {
    return User(id: id, name: name);
  }
}

// Data Layer - Repository 구현체
class SupabaseAuthRepository implements AuthRepository {
  final AuthDatasource _datasource;
  
  @override
  Future<Result<User?>> snsLogin(AuthProvider provider) {
    return _datasource.snsLogin(provider);
  }
}
```

#### 3. Presentation Layer (프레젠테이션 레이어)

**목적**: UI와 사용자 상호작용 처리

**구성요소**:
- **View**: UI 컴포넌트 (Screens, Widgets)
  - 사용자 입력 처리
  - ViewModel과 상호작용
- **ViewModel**: UI 상태 관리
  - Use Case를 통해 비즈니스 로직 실행
  - Riverpod StateNotifier 사용
- **Providers**: 의존성 주입 설정
  - Use Case, Repository 등 Provider로 제공

**예시**:
```dart
// Presentation Layer - ViewModel
class AuthViewModel extends StateNotifier<Result<User?>> {
  final SignInUseCase _signInUseCase;  // Use Case 사용
  
  Future<void> signIn(AuthProvider provider) async {
    state = Pending<User?>('로그인 중...');
    final result = await _signInUseCase(provider);
    state = result;
  }
}
```

### Clean Architecture의 장점

#### 1. **비즈니스 로직 독립성**
- Domain Layer는 외부 의존성이 없어 순수하게 유지
- 프레임워크나 데이터베이스 변경 시도 비즈니스 로직 영향 없음

#### 2. **테스트 용이성**
- Use Case를 독립적으로 테스트 가능 (Mock Repository 사용)
- Repository 인터페이스를 통해 테스트 코드 작성 용이

#### 3. **확장성**
- 새로운 기능 추가 시 Use Case만 추가하면 됨
- 여러 백엔드 지원 시 Repository 구현체만 추가

#### 4. **유지보수성**
- 각 레이어의 책임이 명확히 분리
- 변경 시 영향 범위가 명확함

#### 5. **백엔드 독립성**
- Supabase → Firebase로 교체 시 Repository 구현체만 변경
- Domain Layer와 Use Case는 그대로 유지

### Use Case 패턴의 이점

- **단일 책임 원칙**: 하나의 Use Case는 하나의 작업만 수행
- **재사용성**: 여러 ViewModel에서 동일한 Use Case 재사용 가능
- **테스트 용이성**: 비즈니스 로직을 독립적으로 테스트 가능
- **명확한 의도**: Use Case 이름만으로 기능 파악 가능

### Repository 패턴의 이점

- **의존성 역전**: ViewModel은 구체적인 구현이 아닌 인터페이스에 의존
- **백엔드 교체 용이**: 인터페이스는 유지하고 구현체만 교체
- **테스트 용이**: Mock Repository를 쉽게 생성 가능

### DTO 패턴의 이점

- **도메인 순수성**: Entity는 외부 의존성 없이 순수하게 유지
- **변환 책임 분리**: DTO → Entity 변환 로직이 명확
- **JSON 직렬화 분리**: Domain Entity는 JSON 직렬화 코드 불필요

## 문서

프로젝트 관련 상세 문서는 `docs/` 폴더를 참고하세요.

### 필수 문서

- [문서 폴더 구조](docs/README.md) - 전체 문서 구조 및 빠른 검색
- [아키텍처 가이드](docs/개발/아키텍처.md) - Clean Architecture 상세 설명
- [프로젝트 파일 구조](docs/개발/프로젝트_파일_구조.md) - 디렉토리 구조 설명

### 설정 가이드

- [Supabase 초기 설정](docs/설정/Supabase_초기_설정_가이드.md) - Supabase 프로젝트 생성
- [데이터베이스 초기 설정](docs/개발/데이터베이스/초기_설정_가이드.md) - 스키마 생성
- [소셜 로그인 완전 가이드](docs/설정/소셜_로그인_완전_가이드.md) - 소셜 로그인 구현
- [Storage 초기 설정](docs/설정/Storage/초기_설정_가이드.md) - 이미지 저장 설정
- [홈 화면 위젯 구현 가이드](docs/설정/위젯_구현_가이드.md) - 위젯 구현
- [푸시 알림 완전 가이드](docs/설정/푸시_알림_완전_가이드.md) - 푸시 알림 구현
- [다국어 지원 가이드](docs/설정/다국어_가이드.md) - 다국어 설정 및 사용
- [앱 환경정보 관리](docs/설정/앱_환경정보_관리_가이드.md) - 환경 변수 관리


## 관련 프로젝트

이 프로젝트와 비교할 수 있는 다른 버전:

- **LionSNS-MVVM**: 간결한 MVVM 패턴을 사용한 버전
  - Datasource 직접 사용
  - Repository 패턴 미사용
  - 실용적 접근
  - 중소규모 프로젝트에 적합

**비교**:

| 특징 | Clean Architecture (이 프로젝트) | MVVM |
|------|-------------------------------|------|
| 복잡도 | 높음 | 낮음 |
| 개발 속도 | 느림 | 빠름 |
| 테스트 용이성 | 높음 | 보통 |
| 확장성 | 높음 | 보통 |
| 백엔드 교체 | 용이 | 어려움 |
| 학습 곡선 | 높음 | 낮음 |
| 적합한 프로젝트 | 대규모, 장기 유지보수 | 중소규모, 빠른 개발 |

## 프로젝트 목표

- **Clean Architecture 완전 적용**: 레이어 분리와 의존성 역전 원칙 준수
- **테스트 가능한 코드**: 각 레이어를 독립적으로 테스트 가능
- **확장 가능한 구조**: 새로운 기능 추가 시 기존 코드에 영향 최소화
- **유지보수성**: 명확한 책임 분리로 코드 이해 및 수정 용이
- **학습 자료**: Clean Architecture 학습을 위한 실전 예제

## 라이선스

이 프로젝트는 교육용으로 제작되었습니다.
