import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/agent_model.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});

  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  final _repo = HomeRepository();
  List<AgentModel> _agents = [];
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
      final agents = await _repo.getAgents();
      if (mounted) setState(() { _agents = agents; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          title: const Text('قائمة المندوبين', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
                ? _buildErrorState()
                : _agents.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _agents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _AgentCard(
                            agent: _agents[index],
                            onCall: () => _call(_agents[index].phone),
                            onWhatsapp: () => _whatsapp(_agents[index].whatsapp),
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('لا يوجد مندوبين حالياً', style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('تعذّر تحميل القائمة', style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 12),
        Center(child: TextButton(onPressed: _load, child: const Text('إعادة المحاولة'))),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  final AgentModel agent;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  const _AgentCard({required this.agent, required this.onCall, required this.onWhatsapp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEBF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFEDEBF5),
                child: Icon(Icons.person, color: Color(0xFF2E2B5C)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
                    if (agent.city != null && agent.city!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(agent.city!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E2B5C),
                    side: const BorderSide(color: Color(0xFF2E2B5C)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onWhatsapp,
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text('واتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
