import 'package:dio/dio.dart' as dio;
import '../../../../core/services/api_client.dart';

class ApiAuthService {
  static Future<dio.Response> signIn(String email, String password) async {
    final payload = {'email': email, 'password': password};
    return ApiClient.post('/auth/login', data: payload);
  }

  static Future<dio.Response> signUp(String email, String password, String fullName) async {
    final payload = {'email': email, 'password': password, 'fullName': fullName};
    return ApiClient.post('/auth/signup', data: payload);
  }
}
