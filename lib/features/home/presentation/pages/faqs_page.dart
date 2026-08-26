import 'package:flutter/material.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/faq_model.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  final _repo = HomeRepository();
  List<FaqModel> _faqs = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final faqs = await _repo.getFaqs();
      if (mounted) setState(() { _faqs = faqs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
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
          title: const Text('الأسئلة الشائعة', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
                ? _buildErrorState()
                : _faqs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _faqs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _FaqTile(faq: _faqs[index]),
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.help_outline_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('لا توجد أسئلة شائعة حالياً', style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('تعذّر تحميل الأسئلة', style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: _load, child: const Text('إعادة المحاولة'))),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEBF5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq.questionAr,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerRight,
          children: [
            Text(
              faq.answerAr,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A4760), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
