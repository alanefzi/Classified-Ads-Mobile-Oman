import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  final String? redirectTo;
  const LoginPage({super.key, this.redirectTo});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'عبّي رقم الهاتف وكلمة المرور');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      // نضيف +968 تلقائياً لو المستخدم ما كتبها
      final fullPhone = phone.startsWith('+968') ? phone : '+968$phone';
      await AuthState.instance.login(phone: fullPhone, password: password);

      if (mounted) {
        if (widget.redirectTo != null) {
          context.go(widget.redirectTo!);
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => context.go('/home'),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'تسجيل الدخول لنشر إعلان',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'جاهز للبيع؟ سجّل الدخول وابدأ في نشر إعلاناتك الآن!',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 28),

                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: 'xxxxxxxx',
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                            ),
                          ),
                          Container(
                            height: 44,
                            width: 1,
                            color: AppColors.border,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('+968', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        textAlign: TextAlign.right,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'كلمة المرور',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('تسجيل الدخول'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/register'),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            children: [
                              TextSpan(text: 'ليس لديك حساب؟ '),
                              TextSpan(
                                text: 'قم بإنشاء حساب جديد',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}