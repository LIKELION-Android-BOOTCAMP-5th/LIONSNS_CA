import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../external/supabase_service.dart';
import 'storage_service_interface.dart';

/// Supabase 기반 StorageService 구현
class SupabaseStorageService implements StorageService {
  static const String _profileBucketName = 'profile-images';
  static const String _postBucketName = 'post-images';

  @override
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      debugPrint('[SupabaseStorageService] 프로필 이미지 업로드 시작');
      debugPrint('[SupabaseStorageService] 버킷명: $_profileBucketName');
      debugPrint('[SupabaseStorageService] userId: $userId');
      debugPrint('[SupabaseStorageService] 이미지 파일 경로: ${imageFile.path}');
      debugPrint('[SupabaseStorageService] 이미지 파일 존재: ${await imageFile.exists()}');

      // 파일 존재 확인
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }

      // 파일 크기 확인
      final fileSize = await imageFile.length();
      debugPrint('[SupabaseStorageService] 이미지 파일 크기: ${fileSize} bytes');

      // 파일 경로 생성: {userId}/profile.jpg
      final filePath = '$userId/profile.jpg';
      debugPrint('[SupabaseStorageService] Storage 파일 경로: $filePath');

      // 버킷 존재 확인
      try {
        final buckets = await SupabaseService.client.storage.listBuckets();
        debugPrint('[SupabaseStorageService] 사용 가능한 버킷 목록: ${buckets.map((b) => b.name).toList()}');
        
        if (!buckets.any((b) => b.name == _profileBucketName)) {
          throw Exception('버킷 "$_profileBucketName"이 존재하지 않습니다. Supabase 대시보드에서 버킷을 생성해주세요.');
        }
      } catch (e) {
        debugPrint('[SupabaseStorageService] 버킷 확인 실패 (업로드 계속 시도): $e');
      }

      // 기존 이미지가 있으면 삭제
      try {
        await SupabaseService.client.storage
            .from(_profileBucketName)
            .remove([filePath]);
        debugPrint('[SupabaseStorageService] 기존 이미지 삭제 완료');
      } catch (e) {
        // 기존 이미지가 없을 수 있으므로 무시
        debugPrint('[SupabaseStorageService] 기존 이미지 없음: $e');
      }

      // 이미지 업로드
      debugPrint('[SupabaseStorageService] 이미지 업로드 시도 중...');
      await SupabaseService.client.storage
          .from(_profileBucketName)
          .upload(
        filePath,
        imageFile,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      debugPrint('[SupabaseStorageService] 이미지 업로드 완료');

      // Public URL 가져오기
      final publicUrl = SupabaseService.client.storage
          .from(_profileBucketName)
          .getPublicUrl(filePath);

      debugPrint('[SupabaseStorageService] Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('[SupabaseStorageService] 프로필 이미지 업로드 실패: $e');
      debugPrint('[SupabaseStorageService] 에러 타입: ${e.runtimeType}');
      debugPrint('[SupabaseStorageService] 스택: $stackTrace');
      
      // Supabase Storage 관련 에러인 경우 더 자세한 정보 출력
      if (e.toString().contains('bucket') || e.toString().contains('storage') || e.toString().contains('row-level security')) {
        debugPrint('[SupabaseStorageService] Storage 에러 감지 - 버킷명: $_profileBucketName');
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadPostImage({
    required File imageFile,
    required String postId,
    required String userId,
  }) async {
    try {
      debugPrint('[SupabaseStorageService] 게시글 이미지 업로드 시작');
      debugPrint('[SupabaseStorageService] 버킷명: $_postBucketName');
      debugPrint('[SupabaseStorageService] postId: $postId, userId: $userId');
      debugPrint('[SupabaseStorageService] 이미지 파일 경로: ${imageFile.path}');
      debugPrint('[SupabaseStorageService] 이미지 파일 존재: ${await imageFile.exists()}');

      // 파일 존재 확인
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }

      // 파일 크기 확인
      final fileSize = await imageFile.length();
      debugPrint('[SupabaseStorageService] 이미지 파일 크기: ${fileSize} bytes');

      // 파일 확장자 가져오기
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final contentType = _getContentType(fileExtension);
      debugPrint('[SupabaseStorageService] 파일 확장자: $fileExtension, Content-Type: $contentType');

      // 파일 경로 생성: {userId}/{postId}/{timestamp}.{extension}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/$postId/$timestamp.$fileExtension';
      debugPrint('[SupabaseStorageService] Storage 파일 경로: $filePath');

      // 버킷 존재 확인 및 업로드
      try {
        // 버킷 목록 조회 (디버그용)
        final buckets = await SupabaseService.client.storage.listBuckets();
        debugPrint('[SupabaseStorageService] 사용 가능한 버킷 목록: ${buckets.map((b) => b.name).toList()}');
        
        if (!buckets.any((b) => b.name == _postBucketName)) {
          throw Exception('버킷 "$_postBucketName"이 존재하지 않습니다. Supabase 대시보드에서 버킷을 생성해주세요.');
        }
      } catch (e) {
        debugPrint('[SupabaseStorageService] 버킷 확인 실패 (업로드 계속 시도): $e');
      }

      // 이미지 업로드
      debugPrint('[SupabaseStorageService] 이미지 업로드 시도 중...');
      await SupabaseService.client.storage
          .from(_postBucketName)
          .upload(
        filePath,
        imageFile,
        fileOptions: FileOptions(
          upsert: false,
          contentType: contentType,
        ),
      );

      debugPrint('[SupabaseStorageService] 이미지 업로드 완료');

      // Public URL 가져오기
      final publicUrl = SupabaseService.client.storage
          .from(_postBucketName)
          .getPublicUrl(filePath);

      debugPrint('[SupabaseStorageService] Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('[SupabaseStorageService] 게시글 이미지 업로드 실패: $e');
      debugPrint('[SupabaseStorageService] 에러 타입: ${e.runtimeType}');
      debugPrint('[SupabaseStorageService] 스택: $stackTrace');
      
      // Supabase Storage 관련 에러인 경우 더 자세한 정보 출력
      if (e.toString().contains('bucket') || e.toString().contains('storage')) {
        debugPrint('[SupabaseStorageService] Storage 에러 감지 - 버킷명: $_postBucketName');
      }
      rethrow;
    }
  }

  @override
  Future<void> deletePostImage(String imageUrl) async {
    try {
      debugPrint('[SupabaseStorageService] 게시글 이미지 삭제 시작: $imageUrl');

      // URL에서 파일 경로 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // 'post-images' 이후의 경로 찾기
      final bucketIndex = pathSegments.indexOf('post-images');
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid image URL: $imageUrl');
      }

      // 파일 경로 구성: userId/postId/timestamp.jpg
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // 이미지 삭제
      await SupabaseService.client.storage
          .from(_postBucketName)
          .remove([filePath]);

      debugPrint('[SupabaseStorageService] 게시글 이미지 삭제 완료');
    } catch (e, stackTrace) {
      debugPrint('[SupabaseStorageService] 게시글 이미지 삭제 실패: $e');
      debugPrint('   스택: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<File?> pickImage(ImageSource source) async {
    try {
      debugPrint('[SupabaseStorageService] 이미지 선택 시작: $source');

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('[SupabaseStorageService] 이미지 선택 취소');
        return null;
      }

      debugPrint('[SupabaseStorageService] 이미지 선택 완료: ${image.path}');
      return File(image.path);
    } catch (e, stackTrace) {
      debugPrint('[SupabaseStorageService] 이미지 선택 실패: $e');
      debugPrint('   스택: $stackTrace');
      rethrow;
    }
  }

  /// 파일 확장자에 따른 Content-Type 반환
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

