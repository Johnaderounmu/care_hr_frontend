import 'package:dio/dio.dart' as dio;
import '../../../../core/services/api_client.dart';

class ApiDocumentService {
  static Future<dio.Response> listDocuments(
      {Map<String, dynamic>? filters}) async {
    return ApiClient.get('/documents', queryParameters: filters);
  }

  static Future<dio.Response> uploadDocument(
      Map<String, dynamic> metadata, List<int> bytes) async {
    // Example: this expects the backend to provide a presigned URL or accept multipart
    final formData = dio.FormData.fromMap({
      'metadata': metadata,
      'file': dio.MultipartFile.fromBytes(bytes,
          filename: metadata['filename'] ?? 'upload.bin'),
    });

    return ApiClient.post('/documents/upload', data: formData);
  }
}
