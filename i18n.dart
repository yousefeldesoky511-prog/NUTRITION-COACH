import 'db.dart';

const _s = <String, Map<String, String>>{
  'en': {
    'home': 'Home', 'progress': 'Progress', 'menu': 'Menu', 'hello': 'Good morning!',
    'daily': 'Daily intake', 'left': 'kcal left', 'eaten': 'Eaten', 'target': 'Target',
    'kcal': 'Calories', 'protein': 'Protein', 'fat': 'Fat', 'carbs': 'Carbs',
    'meals': 'Meals', 'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner', 'snack': 'Snack',
    'add_meal': 'Add meal', 'name': 'Meal name', 'save': 'Save', 'cancel': 'Cancel', 'photo': 'Take photo',
    'week': '7 days', 'month': '30 days', 'weight': 'Weight', 'add_weight': 'Add weight (kg)',
    'profile': 'Profile & goal', 'sex': 'Sex', 'male': 'Male', 'female': 'Female', 'age': 'Age',
    'height': 'Height (cm)', 'cur_weight': 'Current weight (kg)', 'target_weight': 'Target weight (kg, optional)',
    'activity': 'Activity', 'low': 'Low', 'mid': 'Moderate', 'high': 'High',
    'ideal': 'Ideal weight', 'goal_kcal': 'Daily calories', 'language': 'Language',
    'backup': 'Backup', 'export': 'Copy backup', 'import': 'Restore from clipboard',
    'copied': 'Backup copied to clipboard', 'imported': 'Backup restored', 'bad': 'Invalid backup',
    'empty': 'No meals yet. Tap + to add one.',
    'disclaimer': 'Guidance only, not medical advice. Calories never go below a safe minimum.',
    'saved': 'Saved',
  },
  'ar': {
    'home': 'الرئيسية', 'progress': 'التقدم', 'menu': 'القائمة', 'hello': 'صباح الخير!',
    'daily': 'المتناول اليومي', 'left': 'سعرة متبقية', 'eaten': 'تم تناوله', 'target': 'الهدف',
    'kcal': 'السعرات', 'protein': 'بروتين', 'fat': 'دهون', 'carbs': 'كارب',
    'meals': 'الوجبات', 'breakfast': 'فطار', 'lunch': 'غداء', 'dinner': 'عشاء', 'snack': 'سناك',
    'add_meal': 'إضافة وجبة', 'name': 'اسم الوجبة', 'save': 'حفظ', 'cancel': 'إلغاء', 'photo': 'التقاط صورة',
    'week': '٧ أيام', 'month': '٣٠ يوم', 'weight': 'الوزن', 'add_weight': 'أضف الوزن (كجم)',
    'profile': 'الملف والهدف', 'sex': 'النوع', 'male': 'ذكر', 'female': 'أنثى', 'age': 'السن',
    'height': 'الطول (سم)', 'cur_weight': 'الوزن الحالي (كجم)', 'target_weight': 'الوزن المستهدف (كجم، اختياري)',
    'activity': 'النشاط', 'low': 'قليل', 'mid': 'متوسط', 'high': 'عالي',
    'ideal': 'الوزن المثالي', 'goal_kcal': 'السعرات اليومية', 'language': 'اللغة',
    'backup': 'نسخة احتياطية', 'export': 'نسخ النسخة الاحتياطية', 'import': 'استرجاع من الحافظة',
    'copied': 'تم نسخ النسخة الاحتياطية', 'imported': 'تم الاسترجاع', 'bad': 'نسخة غير صالحة',
    'empty': 'مفيش وجبات لسه. اضغط + للإضافة.',
    'disclaimer': 'إرشادات فقط وليست نصيحة طبية. السعرات لا تقل عن حد أدنى آمن.',
    'saved': 'تم الحفظ',
  },
};

String t(String k) => _s[Store.lang.value]![k] ?? k;

const _dEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dAr = ['اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد'];
String dn(int weekday) => (Store.lang.value == 'ar' ? _dAr : _dEn)[weekday - 1];
