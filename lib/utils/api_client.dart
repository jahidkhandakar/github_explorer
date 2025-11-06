import 'package:dio/dio.dart';
import 'env.dart';
import 'package:get/get.dart';
import '../mvc/controller/auth_controller.dart';

class ApiClient {
  ApiClient._();
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    },
  ))
    ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      final ghToken = auth?.currentToken();
      final pat = Env.githubPat;

      final token = (ghToken != null && ghToken.isNotEmpty) ? ghToken
                   : (pat != null && pat.isNotEmpty) ? pat
                   : null;

      if (token != null) o.headers['Authorization'] = 'Bearer $token';
      h.next(o);
    }))
    ..interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
}