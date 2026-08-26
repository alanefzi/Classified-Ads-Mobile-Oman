import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/data/models/country_model.dart';
import '../../../home/presentation/pages/static_page_viewer.dart';

class RegisterPage extends StatefulWidget {
  final String? redirectTo;
  const RegisterPage({super.key, this.redirectTo});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _homeRepo = HomeRepository();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorMessage;

  List<CountryModel> _countries = [];
  bool _loadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    try {
      final countries = await _homeRepo.getCountries();
      if (mounted) setState(() { _countries = countries; _loadingCountries = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  int? get _omanCountryId {
    if (_countries.isEmpty) return null;
    final oman = _countries.where((c) => c.nameAr.contains('عُمان') || c.nameAr.contains('عمان')).toList();
    return oman.isNotEmpty ? oman.first.id : _countries.first.id;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'عبّي رقم الهاتف والاسم وكلمة المرور');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'كلمة المرور 8 أحرف أو أرقام على الأقل');
      return;
    }
    final countryId = _omanCountryId;
    if (countryId == null) {
      setState(() => _errorMessage = 'تعذّر تحديد الدولة، حاول مرة ثانية بعد شوي');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final fullPhone = phone.startsWith('+968') ? phone : '+968$phone';
      await AuthState.instance.register(
        name: name,
        phone: fullPhone,
        email: _emailController.text,
        password: password,
        countryId: countryId,
      );

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'من خلال التسجيل، ستحصل على صلاحية كاملة للاستفادة من جميع مزايانا! اسرع!',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),

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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Text('🇴🇲', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 6),
                            Text('+968', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      Container(height: 44, width: 1, color: AppColors.border),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            hintText: 'XXXXXXXX',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                _buildTextField(controller: _nameController, hint: 'الاسم'),
                const SizedBox(height: 14),

                _buildTextField(controller: _emailController, hint: 'البريد الإلكتروني', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.right,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('على الاقل ٨ ارقام او حروف', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_submitting || _loadingCountries) ? null : _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('إنشاء حساب جديد'),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('لديك حساب بالفعل؟ قم بتسجيل الدخول'),
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: Column(
                    children: [
                      const Text(
                        'باستخدام تطبيق Basary Souq، فإنك توافق على',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StaticPageViewer(
                                slug: 'terms-and-conditions',
                                fallbackTitle: 'الشروط والأحكام',
                              ),
                            ),
                          );
                        },
                        child: const Text('الشروط والاحكام', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}