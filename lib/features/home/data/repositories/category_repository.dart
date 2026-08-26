import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data['data'];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الفئات: $e');
    }
  }
}