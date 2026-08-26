import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import 'auth_repository.dart';

/// حالة تسجيل الدخول الحقيقية — تخزّن الـ Token على الجهاز وتربطه تلقائياً
/// بكل طلبات الشبكة الجاية (عبر إضافته لهيدر Authorization بشكل دائم)
class AuthState extends ChangeNotifier {
  AuthState._internal();
  static final AuthState instance = AuthState._internal();

  static const _tokenKey = 'auth_token';
  final _repo = AuthRepository();

  String? _token;
  bool get isLoggedIn => _token != null;

  /// يُستدعى مرة وحدة بأول main.dart — يرجّع تسجيل الدخول تلقائياً لو فيه توكن محفوظ
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    if (_token != null) {
      DioClient.instance.dio.options.headers['Authorization'] = 'Bearer $_token';
    }
    notifyListeners();
  }

  /// تسجيل دخول حقيقي — يرمي Exception برسالة عربية واضحة عند الفشل
  Future<void> login({required String phone, required String password}) async {
    final token = await _repo.login(phone: phone, password: password);
    await _saveToken(token);
  }

  /// إنشاء حساب جديد — يسجّل دخول تلقائياً عند النجاح
  Future<void> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required int countryId,
  }) async {
    final token = await _repo.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      countryId: countryId,
    );
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    DioClient.instance.dio.options.headers['Authorization'] = 'Bearer $token';
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    DioClient.instance.dio.options.headers.remove('Authorization');

    notifyListeners();
  }
}