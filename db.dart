import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

typedef Row = Map<String, Object?>;

class Store {
  static late Database db;
  static final lang = ValueNotifier<String>('en');
  static final tick = ValueNotifier<int>(0);
  static Map<String, dynamic> profile = {};

  static Future<void> init() async {
    db = await openDatabase(p.join(await getDatabasesPath(), 'nutrition.db'), version: 1,
        onCreate: (d, v) async {
      await d.execute('CREATE TABLE meals(id INTEGER PRIMARY KEY AUTOINCREMENT, ts INTEGER, type TEXT, name TEXT, kcal REAL, protein REAL, fat REAL, carbs REAL, photo TEXT)');
      await d.execute('CREATE TABLE weights(id INTEGER PRIMARY KEY AUTOINCREMENT, ts INTEGER, kg REAL)');
      await d.execute('CREATE TABLE kv(k TEXT PRIMARY KEY, v TEXT)');
    });
    final pr = await _get('profile');
    if (pr != null) profile = jsonDecode(pr);
    lang.value = (await _get('lang')) ?? 'en';
  }

  static Future<String?> _get(String k) async {
    final r = await db.query('kv', where: 'k=?', whereArgs: [k]);
    return r.isEmpty ? null : r.first['v'] as String;
  }

  static Future<void> _set(String k, String v) =>
      db.insert('kv', {'k': k, 'v': v}, conflictAlgorithm: ConflictAlgorithm.replace);

  static void _bump() => tick.value++;

  static Future<void> setLang(String l) async { await _set('lang', l); lang.value = l; }

  static Future<void> saveProfile(Map<String, dynamic> pr) async {
    profile = pr;
    await _set('profile', jsonEncode(pr));
    if (pr['weight'] != null) await addWeight((pr['weight'] as num).toDouble());
    _bump();
  }

  static Future<void> addMeal(Row m) async { await db.insert('meals', m); _bump(); }
  static Future<void> delMeal(int id) async { await db.delete('meals', where: 'id=?', whereArgs: [id]); _bump(); }

  static int _start(DateTime d) => DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  static Future<List<Row>> meals(DateTime d) => db.query('meals',
      where: 'ts>=? AND ts<?', whereArgs: [_start(d), _start(d.add(const Duration(days: 1)))], orderBy: 'ts');

  // kcal per day, oldest -> newest, ending today
  static Future<List<double>> dailyKcal(int days) async {
    final now = DateTime.now();
    final out = <double>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final r = await db.rawQuery('SELECT SUM(kcal) s FROM meals WHERE ts>=? AND ts<?',
          [_start(d), _start(d.add(const Duration(days: 1)))]);
      out.add((r.first['s'] as num?)?.toDouble() ?? 0);
    }
    return out;
  }

  static Future<void> addWeight(double kg) async {
    await db.insert('weights', {'ts': DateTime.now().millisecondsSinceEpoch, 'kg': kg});
    _bump();
  }

  static Future<List<Row>> weights() => db.query('weights', orderBy: 'ts DESC', limit: 30);

  // Mifflin-St Jeor + BMI 22 ideal weight. Guidance only.
  static Map<String, double> plan() {
    final pr = profile;
    if (pr.isEmpty) return {'ideal': 0, 'kcal': 2000, 'p': 100, 'f': 65, 'c': 250};
    final w = (pr['weight'] as num).toDouble(), h = (pr['height'] as num).toDouble();
    final a = (pr['age'] as num).toDouble();
    final male = pr['sex'] == 'm';
    final ideal = 22 * (h / 100) * (h / 100);
    final goal = ((pr['target'] ?? ideal) as num).toDouble();
    final bmr = 10 * w + 6.25 * h - 5 * a + (male ? 5 : -161);
    final tdee = bmr * (const {'low': 1.3, 'mid': 1.55, 'high': 1.75}[pr['act']] ?? 1.4);
    var k = goal < w - 0.5 ? tdee - 500 : (goal > w + 0.5 ? tdee + 300 : tdee);
    final minK = male ? 1500.0 : 1200.0;
    if (k < minK) k = minK;
    final prot = 1.6 * goal;
    final fat = k * 0.25 / 9;
    final carb = ((k - prot * 4 - fat * 9) / 4).clamp(0, 1000).toDouble();
    return {'ideal': ideal, 'kcal': k.roundToDouble(), 'p': prot.roundToDouble(), 'f': fat.roundToDouble(), 'c': carb.roundToDouble()};
  }

  static Future<String> exportJson() async => jsonEncode({
        'v': 1,
        'profile': profile,
        'meals': await db.query('meals'),
        'weights': await db.query('weights'),
      });

  static Future<bool> importJson(String s) async {
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      await db.delete('meals');
      await db.delete('weights');
      for (final r in (m['meals'] as List)) { await db.insert('meals', Map<String, Object?>.from(r)..remove('id')); }
      for (final r in (m['weights'] as List)) { await db.insert('weights', Map<String, Object?>.from(r)..remove('id')); }
      profile = Map<String, dynamic>.from(m['profile'] ?? {});
      await _set('profile', jsonEncode(profile));
      _bump();
      return true;
    } catch (_) { return false; }
  }
}
