import 'package:dio/dio.dart' as dio;
import '../../../../core/services/api_client.dart';

class ApiJobService {
  static Future<dio.Response> listJobs({Map<String, dynamic>? filters}) async {
    return ApiClient.get('/jobs', queryParameters: filters);
  }

  static Future<dio.Response> applyJob(
      String jobId, Map<String, dynamic> application) async {
    return ApiClient.post('/jobs/$jobId/apply', data: application);
  }
}
