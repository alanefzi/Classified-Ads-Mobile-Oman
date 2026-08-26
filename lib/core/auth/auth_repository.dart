import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  /// تسجيل دخول حقيقي — يرجّع الـ Token عند النجاح
  Future<String> login({required String phone, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
      }

      return response.data['data']['token'] as String;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'رقم الهاتف أو كلمة السر غير صحيحة';
      throw Exception(message);
    }
  }

  /// إنشاء حساب جديد — يرجّع الـ Token عند النجاح (يسجّل دخول تلقائياً بعد التسجيل)
  Future<String> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required int countryId,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'email': (email == null || email.trim().isEmpty) ? null : email.trim(),
        'password': password,
        // الباك اند يتطلب تأكيد كلمة السر (confirmed) — نرسل نفس القيمة تلقائياً
        // بما إن تصميم الشاشة يعرض حقل كلمة مرور واحد بس
        'password_confirmation': password,
        'country_id': countryId,
      });

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل إنشاء الحساب');
      }

      return response.data['data']['token'] as String;
    } on DioException catch (e) {
      // نعرض أول رسالة خطأ فعلية لو فيه أخطاء تحقق (422)، وإلا رسالة عامة
      final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final firstError = (errors.values.first as List).first;
        throw Exception(firstError.toString());
      }
      final message = e.response?.data?['message'] ?? 'تعذّر إنشاء الحساب، حاول مرة ثانية';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // نتجاهل أي خطأ هنا — بنمسح التوكن محلياً بغض النظر
    }
  }
}