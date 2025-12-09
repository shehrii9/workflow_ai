import 'package:dio/dio.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/features/execution/executors/base_executor.dart';

class HttpExecutor extends NodeExecutor {
  final Dio _dio = Dio();

  @override
  bool canExecute(String nodeType) => nodeType == 'http';

  @override
  Future<Map<String, dynamic>> execute(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    final config = node.configuration;
    final method = config['method'] as String? ?? 'GET';
    final url = config['url'] as String? ?? '';

    if (url.isEmpty) {
      throw Exception('URL is required for HTTP request');
    }

    try {
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url);
          break;
        case 'POST':
          response = await _dio.post(
            url,
            data: config['body'] ?? inputData,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: config['body'] ?? inputData,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(url);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return {
        'statusCode': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
      };
    } catch (e) {
      throw Exception('HTTP request failed: $e');
    }
  }
}

