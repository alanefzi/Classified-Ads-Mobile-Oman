import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/static_page_viewer.dart';
import '../../../home/presentation/pages/agents_page.dart';
import '../../../home/presentation/pages/recently_viewed_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: AuthState.instance,
            builder: (context, _) {
              final isLoggedIn = AuthState.instance.isLoggedIn;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                            onPressed: () => _showSoon(context),
                          ),
                        ),
                        isLoggedIn ? _buildLoggedInHeader(context) : _buildGuestHeader(context),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  if (isLoggedIn) ...[
                    _NavRow(
                      icon: Icons.list_alt_rounded,
                      label: 'إعلاناتي',
                      onTap: () => _showSoon(context),
                    ),
                    const Divider(height: 1, color: AppColors.border, indent: 20, endIndent: 20),
                  ],

                  _NavRow(
                    icon: Icons.visibility_outlined,
                    label: 'شاهدت مؤخراً',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RecentlyViewedPage()), // تم حذف const لتفادي خطأ Compilation
                    ),
                  ),

                  _SectionHeader('الإعدادات'),
                  _NavRow(
                    icon: Icons.language_rounded,
                    label: 'اللغة',
                    trailing: 'العربية',
                    onTap: () => _showSoon(context),
                  ),

                  _SectionHeader('اتصل بنا'),
                  _NavRow(
                    icon: Icons.location_on_outlined,
                    label: 'قائمة المندوبين',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AgentsPage()),
                    ),
                  ),
                  _NavRow(
                    icon: Icons.headset_mic_outlined,
                    label: 'الدعم الفني',
                    onTap: () => _openPage(context, 'technical-support', 'الدعم الفني'),
                  ),

                  _SectionHeader('أخرى'),
                  _NavRow(
                    icon: Icons.article_outlined,
                    label: 'المدونة',
                    onTap: () => _showSoon(context),
                  ),
                  _NavRow(
                    icon: Icons.info_outline_rounded,
                    label: 'أعرف أكثر',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LearnMorePage()),
                    ),
                  ),

                  if (isLoggedIn) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton.icon(
                        onPressed: () => AuthState.instance.logout(),
                        icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                        label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, size: 34, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('مرحباً بك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text(
                    'سجل الدخول او قم بإنشاء حساب جديد لشراء و بيع كل شيء.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('تسجيل الدخول'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              children: [
                const TextSpan(text: 'ليس لديك حساب؟ '),
                TextSpan(
                  text: 'قم بإنشاء حساب جديد',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()..onTap = () => context.push('/register'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.border,
          child: Icon(Icons.person, size: 34, color: Colors.white),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('حسابي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 4),
            Text('مرحباً بعودتك 👋', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذي الصفحة قريباً')),
    );
  }

  void _openPage(BuildContext context, String slug, String fallbackTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaticPageViewer(slug: slug, fallbackTitle: fallbackTitle),
      ),
    );
  }
}

class LearnMorePage extends StatelessWidget {
  const LearnMorePage({super.key});

  void _openPage(BuildContext context, String slug, String fallbackTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaticPageViewer(slug: slug, fallbackTitle: fallbackTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('أعرف أكثر', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _PolicyCard(
              title: 'سياسة الاستخدام',
              onTap: () => _openPage(context, 'terms-of-use', 'سياسة الاستخدام'),
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              title: 'سياسة الخصوصية',
              onTap: () => _openPage(context, 'privacy-policy', 'سياسة الخصوصية'),
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              title: 'سياسة الاسترجاع والأموال',
              onTap: () => _openPage(context, 'refund-policy', 'سياسة الاسترجاع والأموال'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PolicyCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _NavRow({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Text(trailing!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const Spacer(),
            Transform.rotate(
              angle: 3.14159,
              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}