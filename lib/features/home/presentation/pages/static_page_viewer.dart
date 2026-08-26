import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/page_model.dart';

/// عارض صفحة نصية عامة — يشتغل لأي صفحة تضيفها لاحقاً بلوحة التحكم
class StaticPageViewer extends StatefulWidget {
  final String slug;
  final String fallbackTitle; // يظهر بالـ AppBar لحين ما يوصل عنوان الصفحة الفعلي

  const StaticPageViewer({super.key, required this.slug, required this.fallbackTitle});

  @override
  State<StaticPageViewer> createState() => _StaticPageViewerState();
}

class _StaticPageViewerState extends State<StaticPageViewer> {
  final _repo = HomeRepository();
  PageModel? _page;
  bool _loading = true;
  bool _error = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final page = await _repo.getPage(widget.slug);
      if (mounted) setState(() { _page = page; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
  }

  // وظيفة الاتصال الهاتفي
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // وظيفة فتح الواتساب
  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSoonSnackBar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ميزة $title ستكون متاحة قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E2B5C),
          elevation: 0,
          centerTitle: true,
          title: Text(_page?.titleAr ?? widget.fallbackTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error || _page == null
                ? _buildErrorState()
                : _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (widget.slug == 'technical-support') {
      return _buildTechnicalSupportLayout();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Html(
        data: _page!.contentAr,
        style: {
          'body': Style(fontSize: FontSize(15), color: const Color(0xFF2E2B5C), lineHeight: const LineHeight(1.7)),
        },
      ),
    );
  }

  /// واجهة الدعم الفني المطابقة للتصميم
  Widget _buildTechnicalSupportLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // زر الأسئلة المتكررة — يتم الانتقال عبر go_router
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/faqs');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('الاسئلة المتكررة', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          _buildDivider('او'),

          // حقل البريد الإلكتروني
          TextField(
            controller: _emailController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'البريد الإلكتروني',
              suffixIcon: const Icon(Icons.email_outlined, color: Colors.black87),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('مطلوب', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 16),

          // أزرار تذكراتي وإنشاء تذكرة
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSoonSnackBar('تذكراتي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('تذكراتي', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSoonSnackBar('انشاء تذكرة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('انشاء تذكرة', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          _buildDivider('او'),

          // أزرار محادثة واتصل بنا
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openWhatsApp('+96897034140'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('محادثة', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _makePhoneCall('+96897034140'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('اتصل بنا', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // عنوان نصي بسيط للمساعدة بدلاً من الزر
          const Center(
            child: Text(
              'للمساعدة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2B5C),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // أوقات العمل الرسمية
          const Text(
            'أوقات العمل الرسمية كل يوم من الساعة 9 الى الساعة 12 ليلا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2E2B5C),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('تعذّر تحميل الصفحة', style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: _load, child: const Text('إعادة المحاولة'))),
      ],
    );
  }
}