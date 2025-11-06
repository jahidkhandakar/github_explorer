import 'package:dio/dio.dart';

String friendlyError(Object e) {
  if (e is DioException) {
    final s = e.response?.statusCode ?? 0;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) return 'Connection timed out.';
    if (s == 404) return 'User or resource not found.';
    if (s == 403) return 'Rate limited. Add a token or try later.';
    final msg = (e.response?.data is Map) ? e.response!.data['message'] : null;
    return msg is String && msg.isNotEmpty ? msg : 'Request failed (${s == 0 ? 'network' : s}).';
  }
  return 'Unexpected error. Please retry.';
}