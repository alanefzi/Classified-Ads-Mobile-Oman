import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('المفضلة')),
      body: const Center(child: Text('إعلاناتك المفضلة (قريبًا)')),
    );
  }
}