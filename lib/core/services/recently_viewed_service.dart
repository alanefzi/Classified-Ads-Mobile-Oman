import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// يخزّن أرقام الإعلانات اللي فتحها المستخدم مؤخراً — محلياً على الجهاز بس
/// (بدون أي اتصال بالسيرفر)، الأحدث أول، بحد أقصى 30 إعلان
class RecentlyViewedService {
  RecentlyViewedService._internal();
  static final RecentlyViewedService instance = RecentlyViewedService._internal();

  static const _key = 'recently_viewed_listing_ids';
  static const _maxItems = 30;

  Future<void> addListing(int listingId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getIds(prefs);

    ids.remove(listingId); // نشيله لو موجود أصلاً عشان نرجّعه لأول القائمة
    ids.insert(0, listingId);

    final trimmed = ids.take(_maxItems).toList();
    await prefs.setString(_key, jsonEncode(trimmed));
  }

  Future<List<int>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    return _getIds(prefs);
  }

  Future<List<int>> _getIds(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }
}
