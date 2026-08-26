import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الدردشة')),
      body: const Center(child: Text('محادثاتك (قريبًا)')),
    );
  }
}