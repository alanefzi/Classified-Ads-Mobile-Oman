import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/data/models/city_model.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/data/repositories/listing_repository.dart';
import '../../data/attribute_fields.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _homeRepo = HomeRepository();
  final _listingRepo = ListingRepository();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  bool _loadingLookups = true;
  bool _submitting = false;

  List<CategoryModel> _categories = [];
  List<CityModel> _cities = [];

  CategoryModel? _selectedCategory;
  CityModel? _selectedCity;
  String? _selectedCondition; // 'new' أو 'used'
  bool _isNegotiable = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final Map<String, dynamic> _attributeValues = {};
  final Map<String, TextEditingController> _attributeControllers = {};

  final List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait([_homeRepo.getCategories(), _homeRepo.getCities()]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _cities = results[1] as List<CityModel>;
          _loadingLookups = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLookups = false);
    }
  }

  /// يطلع لأعلى شجرة الفئات لين يوصل الفئة الرئيسية (بدون parent_id)
  CategoryModel? _rootCategoryOf(CategoryModel category) {
    CategoryModel current = category;
    var guard = 0; // حماية من أي حلقة لا نهائية بالبيانات
    while (current.parentId != null && guard < 10) {
      final parentMatch = _categories.where((c) => c.id == current.parentId).toList();
      if (parentMatch.isEmpty) break;
      current = parentMatch.first;
      guard++;
    }
    return current;
  }

  List<AttributeField> get _dynamicFields {
    if (_selectedCategory == null) return [];
    final root = _rootCategoryOf(_selectedCategory!);
    if (root?.nameAr == null) return [];
    return categoryFieldGroups[root!.nameAr] ?? [];
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      _images.addAll(picked.map((x) => File(x.path)));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.id == null) {
      _showError('اختر الفئة أولاً');
      return;
    }
    if (_selectedCity == null) {
      _showError('اختر المدينة أولاً');
      return;
    }

    setState(() => _submitting = true);
    try {
      final listingId = await _listingRepo.createListing(
        categoryId: _selectedCategory!.id!,
        cityId: _selectedCity!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty ? null : double.tryParse(_priceController.text.trim()),
        currency: 'OMR',
        isNegotiable: _isNegotiable,
        condition: _selectedCondition,
        attributes: _collectAttributeValues(),
      );

      if (_images.isNotEmpty) {
        await _listingRepo.uploadImages(listingId, _images);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الإعلان للمراجعة بنجاح')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('تعذّر نشر الإعلان، حاول مرة ثانية');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic> _collectAttributeValues() {
    final result = <String, dynamic>{};
    for (final field in _dynamicFields) {
      final controllerValue = _attributeControllers[field.key]?.text.trim();
      final selectValue = _attributeValues[field.key];
      final value = selectValue ?? controllerValue;
      if (value != null && value.toString().isNotEmpty) {
        result[field.key] = value;
      }
    }
    return result;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  TextEditingController _controllerFor(String key) {
    return _attributeControllers.putIfAbsent(key, () => TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (final c in _attributeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('إضافة إعلان')),
        body: _loadingLookups
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle('الفئة'),
                    DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('اختر الفئة'),
                      isExpanded: true,
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(_categoryDisplayLabel(c))))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (val) => val == null ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    _sectionTitle('العنوان'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('عنوان الإعلان'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    _sectionTitle('المدينة'),
                    DropdownButtonFormField<CityModel>(
                      value: _selectedCity,
                      decoration: _inputDecoration('اختر المدينة'),
                      isExpanded: true,
                      items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr))).toList(),
                      onChanged: (val) => setState(() => _selectedCity = val),
                      validator: (val) => val == null ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    _sectionTitle('السعر (ر.ع)'),
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('السعر (اختياري)'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isNegotiable,
                          onChanged: (val) => setState(() => _isNegotiable = val ?? false),
                        ),
                        const Text('السعر قابل للتفاوض'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _sectionTitle('الحالة'),
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      decoration: _inputDecoration('اختر الحالة (اختياري)'),
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('جديد')),
                        DropdownMenuItem(value: 'used', child: Text('مستعمل')),
                      ],
                      onChanged: (val) => setState(() => _selectedCondition = val),
                    ),
                    const SizedBox(height: 16),

                    // ===== الحقول الديناميكية حسب الفئة =====
                    if (_dynamicFields.isNotEmpty) ...[
                      _sectionTitle('تفاصيل إضافية'),
                      ..._dynamicFields.map(_buildDynamicField),
                      const SizedBox(height: 8),
                    ],

                    _sectionTitle('الوصف'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('اكتب وصف تفصيلي (اختياري)'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    _sectionTitle('الصور'),
                    _buildImagePicker(),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('نشر الإعلان'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  String _categoryDisplayLabel(CategoryModel c) {
    // نضيف مسافة بادئة بسيطة للفئات الفرعية عشان تبان تحت فئتها الرئيسية بالقائمة
    return c.parentId != null ? '  ${c.nameAr}' : (c.nameAr ?? '');
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E2B5C))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildDynamicField(AttributeField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: switch (field.type) {
        FieldType.select => DropdownButtonFormField<String>(
            value: _attributeValues[field.key] as String?,
            decoration: _inputDecoration(field.label),
            isExpanded: true,
            items: (field.options ?? []).map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (val) => setState(() => _attributeValues[field.key] = val),
            validator: field.required ? (val) => val == null ? '${field.label} مطلوب' : null : null,
          ),
        FieldType.number => TextFormField(
            controller: _controllerFor(field.key),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(field.label),
            validator: field.required
                ? (val) => (val == null || val.trim().isEmpty) ? '${field.label} مطلوب' : null
                : null,
          ),
        FieldType.longText => TextFormField(
            controller: _controllerFor(field.key),
            maxLines: 3,
            decoration: _inputDecoration(field.label),
          ),
        FieldType.boolean || FieldType.text => TextFormField(
            controller: _controllerFor(field.key),
            decoration: _inputDecoration(field.label),
            validator: field.required
                ? (val) => (val == null || val.trim().isEmpty) ? '${field.label} مطلوب' : null
                : null,
          ),
      },
    );
  }

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._images.map((file) {
          final index = _images.indexOf(file);
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(file, width: 84, height: 84, fit: BoxFit.cover),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: () => setState(() => _images.removeAt(index)),
                  child: const CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}