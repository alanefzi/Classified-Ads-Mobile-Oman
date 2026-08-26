import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // إضافة مكتبة الإعلانات
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/auth/auth_state.dart';

void main() async { // تحويل main إلى async
  WidgetsFlutterBinding.ensureInitialized();

  // نرجّع تسجيل الدخول تلقائياً لو المستخدم مسجّل دخول من قبل (توكن محفوظ بالجهاز)
  await AuthState.instance.restoreSession();

  // تهيئة AdMob SDK — بس على أندرويد و iOS (Windows/Web ما يدعمها الـ plugin)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  runApp(const BasaryApp());
}

class BasaryApp extends StatelessWidget {
  const BasaryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Basary Souq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      locale: const Locale('ar', 'OM'),
      supportedLocales: const [Locale('ar', 'OM')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}