import '../../../../core/network/dio_client.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/listing_model.dart';
import '../models/city_model.dart';
import '../models/page_model.dart';
import '../models/agent_model.dart';
import '../models/country_model.dart';
import '../models/faq_model.dart';

class HomeRepository {
  final _dio = DioClient.instance.dio;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/categories');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  /// يجيب كل المدن (تُستخدم بنموذج إضافة الإعلان لاختيار مدينة الإعلان)
  Future<List<CityModel>> getCities() async {
    final response = await _dio.get('/cities');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => CityModel.fromJson(e)).toList();
  }

  /// بدون categoryId: يرجّع البانرات العامة (تظهر بالصفحة الرئيسية)
  /// مع categoryId: يرجّع البانرات المستهدفة لتلك الفئة فقط (إعلانات مدفوعة)
  Future<List<BannerModel>> getBanners({int? categoryId}) async {
    final response = await _dio.get(
      '/banners',
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => BannerModel.fromJson(e)).toList();
  }

  /// categoryId: فلترة حسب الفئة (اختياري)
  /// origin: فلترة حسب بلد المنشأ (اختياري) — مواصفة داخل حقل attributes، مو فئة
  Future<List<ListingModel>> getListings({int? categoryId, String? origin}) async {
    final response = await _dio.get(
      '/listings',
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (origin != null) 'origin': origin,
      },
    );
    final data = response.data['data']['data'] as List<dynamic>;
    return data.map((e) => ListingModel.fromJson(e)).toList();
  }

  /// يجيب تفاصيل إعلان واحد كامل (بيانات البائع، الحالة، عدد المشاهدات...)
  /// ملاحظة: شكل الاستجابة هنا مختلف عن getListings — العنصر مباشرة داخل 'data'
  /// بدون تغليف 'data' مضاعف (لأنه مو Paginated زي القائمة)
  Future<ListingModel> getListingDetail(int id) async {
    final response = await _dio.get('/listings/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }

  /// يسجّل ضغطة على فئة (لتتبّع "الأقسام الأكثر بحثاً" لاحقاً)
  /// ما يوقف أو يأثر على أي شي بالواجهة لو فشل — مجرد تسجيل صامت بالخلفية
  Future<void> trackCategoryView(int categoryId) async {
    try {
      await _dio.post('/categories/$categoryId/track-view');
    } catch (_) {
      // نتجاهل أي خطأ هنا عمداً — التتبّع مو حرج لتجربة المستخدم
    }
  }

  /// يجيب صفحة نصية واحدة بالـ Slug (قائمة المندوبين، الدعم الفني، القواعد والشروط...)
  Future<PageModel> getPage(String slug) async {
    final response = await _dio.get('/pages/$slug');
    final data = response.data['data'] as Map<String, dynamic>;
    return PageModel.fromJson(data);
  }

  /// يجيب قائمة المندوبين (اسم، هاتف، واتساب)
  Future<List<AgentModel>> getAgents() async {
    final response = await _dio.get('/agents');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => AgentModel.fromJson(e)).toList();
  }

  /// يجيب قائمة الدول (يستخدمها نموذج إنشاء الحساب)
  Future<List<CountryModel>> getCountries() async {
    final response = await _dio.get('/countries');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => CountryModel.fromJson(e)).toList();
  }

  /// يجيب كل الأسئلة الشائعة
  Future<List<FaqModel>> getFaqs() async {
    final response = await _dio.get('/faqs');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => FaqModel.fromJson(e)).toList();
  }
}