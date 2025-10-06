import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'storage_service.dart';

class ApiClient {
  static late dio.Dio _dio;
  static GraphQLClient? _graphqlClient;

  static void init() {
    // Initialize with fallback values if env vars are not available
    String baseUrl = 'http://localhost:4000';
    String graphqlEndpoint = 'http://localhost:4000/graphql';
    
    try {
      // Try to get values from dotenv, but use fallbacks if not available
      baseUrl = dotenv.env['API_BASE_URL'] ?? baseUrl;
      graphqlEndpoint = dotenv.env['GRAPHQL_ENDPOINT'] ?? graphqlEndpoint;
    } catch (e) {
      // If dotenv is not initialized, use the fallback values
      if (kDebugMode) {
        debugPrint('Using fallback URLs due to dotenv error: $e');
      }
    }
    
    _dio = dio.Dio(dio.BaseOptions(baseUrl: baseUrl));
    
    if (graphqlEndpoint.isNotEmpty) {
      try {
        final link = HttpLink(graphqlEndpoint);
        _graphqlClient = GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: link,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('GraphQL client initialization failed: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
          'ApiClient initialized. REST: ${_dio.options.baseUrl}, GraphQL: $graphqlEndpoint');
    }
    
    // Attach token if present
    try {
      final token = StorageService.getUserToken();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Token retrieval failed during initialization: $e');
      }
    }
  }

  static void setAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Simple REST GET
  static Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // Simple REST POST with JSON body
  static Future<dio.Response> post(String path, {Object? data}) async {
    return _dio.post(path, data: data);
  }

  // GraphQL query
  static Future<QueryResult> graphqlQuery(String query,
      {Map<String, dynamic>? variables}) async {
    if (_graphqlClient == null) {
      throw Exception('GraphQL client not initialized');
    }
    final options =
        QueryOptions(document: gql(query), variables: variables ?? {});
    return _graphqlClient!.query(options);
  }

  // GraphQL mutation
  static Future<QueryResult> graphqlMutate(String mutation,
      {Map<String, dynamic>? variables}) async {
    if (_graphqlClient == null) {
      throw Exception('GraphQL client not initialized');
    }
    final options =
        MutationOptions(document: gql(mutation), variables: variables ?? {});
    return _graphqlClient!.mutate(options);
  }
}
