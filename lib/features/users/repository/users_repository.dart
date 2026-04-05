import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';

class UsersRepository {
  final String apiUrl = "http://192.168.1.20:8000/api/admin/users";

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleUnauthenticated(int statusCode) {
    if (statusCode == 401) {
      TokenManager.clearToken();
      throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
    }
  }

  Future<UsersResponse> fetchUsers({int page = 1}) async {
    try {
      print('[API_GET_USERS] Fetching users page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse("$apiUrl?page=$page"),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_USERS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return UsersResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية للوصول إلى بيانات المستخدمين');
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<UserModel> createUser({
    required String fname,
    required String lname,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
    String? imagePath,
  }) async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers.addAll(await _getHeaders());

        request.fields['fname'] = fname;
        request.fields['lname'] = lname;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.fields['password_confirmation'] = passwordConfirmation;
        if (phone != null) request.fields['phone'] = phone;
        if (address != null) request.fields['address'] = address;

        if (imagePath != null && imagePath.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath('profile_image', imagePath));
        }
        final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
        return await http.Response.fromStream(streamedResponse);
      });

      print('[API_CREATE_USER] Status Code: ${response.statusCode}');

      final decodedResponse = json.decode(response.body);
      if (response.statusCode == 201) {
        return UserModel.fromJson(decodedResponse['data']);
      } else if (response.statusCode == 422) {
        final errors = decodedResponse['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception(decodedResponse['message'] ?? 'خطأ في البيانات المدخلة');
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لإضافة مستخدمين');
      } else {
        String errorMsg = decodedResponse['message'] ?? 'فشل إنشاء المستخدم: ${response.statusCode}';
        if (errorMsg.contains('Duplicate entry') && errorMsg.contains('users_email_unique')) {
          throw Exception('هذا البريد الإلكتروني مسجل مسبقاً، يرجى استخدام بريد آخر.');
        } else if (errorMsg.contains('SQLSTATE')) {
          throw Exception('حدث خطأ غير متوقع في قاعدة البيانات. برجاء المحاولة لاحقاً.');
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<UserModel> fetchUserById(int id) async {
    try {
      print('[API_GET_USER] Fetching user details for id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/$id'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_USER] Status Code: ${response.statusCode}');

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(decodedResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('المستخدم غير موجود أو تم حذفه');
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض بيانات هذا المستخدم');
      } else {
        throw Exception(decodedResponse['message'] ?? 'فشل تحميل بيانات المستخدم: ${response.statusCode}');
      }
    } catch (e) {
      print('[API_GET_USER] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      print('[API_DELETE_USER] Deleting user id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.delete(
          Uri.parse('$apiUrl/$id'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_DELETE_USER] Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('المستخدم غير موجود أو تم حذفه بالفعل');
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لحذف المستخدمين');
      } else if (response.statusCode == 500) {
        final bodyStr = response.body.toLowerCase();
        if (bodyStr.contains('integrity constraint violation') || bodyStr.contains('1451 cannot delete or update a parent row')) {
          throw Exception('لا يمكن حذف هذا المستخدم نظراً لارتباطه ببيانات أخرى في النظام (مثل مشاركته في مزادات حالية).');
        }
        throw Exception('حدث خطأ في الخادم أثناء محاولة الحذف.');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل حذف المستخدم: ${response.statusCode}');
      }
    } catch (e) {
      print('[API_DELETE_USER] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
