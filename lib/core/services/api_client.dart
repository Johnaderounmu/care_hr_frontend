import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'storage_service.dart';

class ApiClient {
  static final dio.Dio _dio =
      dio.Dio(dio.BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));
  static GraphQLClient? _graphqlClient;

  static void init() {
    final graphqlEndpoint = dotenv.env['GRAPHQL_ENDPOINT'];
    if (graphqlEndpoint != null && graphqlEndpoint.isNotEmpty) {
      final link = HttpLink(graphqlEndpoint);
      _graphqlClient = GraphQLClient(
        cache: GraphQLCache(store: InMemoryStore()),
        link: link,
      );
    }

    if (kDebugMode) {
      debugPrint(
          'ApiClient initialized. REST: ${_dio.options.baseUrl}, GraphQL: $graphqlEndpoint');
    }
    // Attach token if present
    final token = StorageService.getUserToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
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
    if (_graphqlClient == null)
      throw Exception('GraphQL client not initialized');
    final options =
        QueryOptions(document: gql(query), variables: variables ?? {});
    return _graphqlClient!.query(options);
  }

  // GraphQL mutation
  static Future<QueryResult> graphqlMutate(String mutation,
      {Map<String, dynamic>? variables}) async {
    if (_graphqlClient == null)
      throw Exception('GraphQL client not initialized');
    final options =
        MutationOptions(document: gql(mutation), variables: variables ?? {});
    return _graphqlClient!.mutate(options);
  }
}
