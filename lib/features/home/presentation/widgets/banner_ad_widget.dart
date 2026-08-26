import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// يتحقق إذا المنصة تدعم AdMob (أندرويد أو iOS فقط)
bool get _isAdsSupportedPlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// ويدجت بانر إعلاني قابل لإعادة الاستخدام (AdMob)
/// استخدمه بأي مكان بالصفحة الرئيسية أو صفحات الفئات
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // ============================================
  // ⚠️ معرّفات اختبار (Test IDs) من جوجل نفسها — شغّالة فوراً بدون حساب AdMob
  // لازم تستبدلها بمعرّفاتك الحقيقية قبل النشر بمتجر التطبيقات (خطوات بالأسفل)
  // ============================================
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  String get _adUnitId {
    // TODO: بعد إنشاء حساب AdMob، استبدل هذا بمعرّف الوحدة الإعلانية الحقيقي
    return _testAndroidBannerId; // عدّلها لو تدعم iOS لاحقاً (Platform.isIOS ? _testIosBannerId : _testAndroidBannerId)
  }

  @override
  void initState() {
    super.initState();
    // ما نحاول تحميل إعلان إطلاقاً على منصة غير مدعومة (Windows/Web)
    if (_isAdsSupportedPlatform) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('فشل تحميل الإعلان: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ما يظهر أي شي على منصات غير مدعومة (Windows/Web) — بدون أي خطأ
    if (!_isAdsSupportedPlatform || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}