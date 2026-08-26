/// تعريف الحقول الديناميكية لكل مجموعة فئات (تُبنى تلقائياً بنموذج إضافة الإعلان)
enum FieldType { text, number, select, boolean, longText }

class AttributeField {
  final String key; // يُحفظ بحقل attributes بقاعدة البيانات
  final String label; // يظهر للمستخدم
  final FieldType type;
  final List<String>? options; // للـ select فقط
  final bool required;

  const AttributeField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.required = false,
  });
}

/// قائمة بلد المنشأ (نفس القائمة المستخدمة بقسم "تصفح حسب المنشأ")
const List<String> originCountries = [
  'صيني', 'أمريكي', 'ياباني', 'ألماني', 'إنجليزي', 'كوري',
  'إيطالي', 'فرنسي', 'سويدي', 'إسباني', 'ماليزي', 'أخرى',
];

/// قائمة "وارد" (مصدر استيراد السيارة تحديداً — مختلف عن بلد المنشأ)
const List<String> importedFromOptions = [
  'سلطنة عمان', 'خليجي', 'اليابان', 'أمريكا', 'كندا', 'أوروبا', 'أخرى',
];

/// حقول كل مجموعة فئات — المفتاح هو اسم الفئة الرئيسية بالضبط زي قاعدة البيانات
final Map<String, List<AttributeField>> categoryFieldGroups = {
  'المركبات': [
    const AttributeField(key: 'brand', label: 'الماركة', type: FieldType.text, required: true),
    const AttributeField(key: 'model', label: 'الموديل', type: FieldType.text, required: true),
    const AttributeField(key: 'origin', label: 'بلد المنشأ', type: FieldType.select, options: originCountries),
    const AttributeField(key: 'year', label: 'سنة الصنع', type: FieldType.number, required: true),
    const AttributeField(
      key: 'body_type',
      label: 'نوع الهيكل',
      type: FieldType.select,
      options: ['سيدان', 'دفع رباعي (SUV)', 'بيك أب', 'كوبيه', 'هاتشباك', 'فان', 'أخرى'],
    ),
    const AttributeField(key: 'mileage', label: 'المسافة المقطوعة (كم)', type: FieldType.number),
    const AttributeField(key: 'exterior_color', label: 'اللون الخارجي', type: FieldType.text),
    const AttributeField(key: 'interior_color', label: 'اللون الداخلي', type: FieldType.text),
    const AttributeField(
      key: 'fuel_type',
      label: 'نوع الوقود',
      type: FieldType.select,
      options: ['بنزين', 'ديزل', 'كهرباء', 'هايبرد'],
    ),
    const AttributeField(
      key: 'transmission',
      label: 'ناقل الحركة',
      type: FieldType.select,
      options: ['أوتوماتيك', 'عادي'],
    ),
    const AttributeField(key: 'imported_from', label: 'وارد', type: FieldType.select, options: importedFromOptions),
    const AttributeField(
      key: 'seat_type',
      label: 'نوع المقاعد',
      type: FieldType.select,
      options: ['جلد', 'قماش', 'أخرى'],
    ),
    const AttributeField(key: 'cylinders', label: 'عدد الأسطوانات', type: FieldType.number),
    const AttributeField(
      key: 'sunroof',
      label: 'فتحة السقف',
      type: FieldType.select,
      options: ['نعم', 'لا'],
    ),
    const AttributeField(
      key: 'inspection_report',
      label: 'تقرير الفحص متوفر',
      type: FieldType.select,
      options: ['نعم', 'لا'],
    ),
    const AttributeField(key: 'specs', label: 'مواصفات إضافية', type: FieldType.longText),
  ],
  'العقارات': [
    const AttributeField(
      key: 'property_type',
      label: 'نوع العقار',
      type: FieldType.select,
      options: ['شقة', 'فيلا', 'أرض', 'محل تجاري', 'مكتب', 'مستودع', 'أخرى'],
      required: true,
    ),
    const AttributeField(key: 'location', label: 'الموقع', type: FieldType.text),
    const AttributeField(key: 'area', label: 'مساحة العقار (م²)', type: FieldType.number, required: true),
    const AttributeField(key: 'floors_count', label: 'عدد الأدوار', type: FieldType.number),
    const AttributeField(key: 'rooms', label: 'عدد الغرف', type: FieldType.number),
    const AttributeField(key: 'halls', label: 'عدد الصالات', type: FieldType.number),
    const AttributeField(key: 'bathrooms', label: 'عدد الحمامات', type: FieldType.number),
    const AttributeField(key: 'specs', label: 'مواصفات إضافية', type: FieldType.longText),
  ],
  'موبايل وتابلت': [
    const AttributeField(key: 'brand', label: 'الماركة', type: FieldType.text, required: true),
    const AttributeField(key: 'model_line', label: 'الفئة', type: FieldType.text),
    const AttributeField(
      key: 'storage',
      label: 'سعة التخزين',
      type: FieldType.select,
      options: ['32GB', '64GB', '128GB', '256GB', '512GB', '1TB', 'أخرى'],
    ),
    const AttributeField(key: 'color', label: 'اللون', type: FieldType.text),
    // ملاحظة: "الحالة" (جديد/مستعمل) مو هنا — موجودة أصلاً كحقل أساسي بكل الإعلانات
  ],
  'إلكترونيات': [
    const AttributeField(key: 'brand', label: 'الماركة', type: FieldType.text, required: true),
  ],
};
