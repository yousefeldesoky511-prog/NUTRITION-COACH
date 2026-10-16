import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'db.dart' as db;
import 'i18n.dart';

const kGreen = Color(0xFF8CCB3A);
const kLime = Color(0xFFCDEFA6);

Widget card(Widget child, {Color color = Colors.white}) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(20)),
    child: child);

double _n(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    const pages = [Home(), ProgressPage(), MenuPage()];
    final idx = i == 0 ? 0 : (i == 1 ? 1 : 2);
    return Scaffold(
      body: SafeArea(child: pages[idx]),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddMeal()),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nav(0, Icons.home_outlined, t('home')),
              _nav(1, Icons.bar_chart, t('progress')),
              const SizedBox(width: 48),
              _nav(2, Icons.grid_view, t('menu')),
            ]),
      ),
    );
  }

  Widget _nav(int n, IconData ic, String label) => InkWell(
      onTap: () => setState(() => i = n),
      child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(ic, color: i == n ? kGreen : Colors.grey),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: i == n ? kGreen : Colors.grey)),
          ])));
}

// ---------------- Home ----------------
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime day = DateTime.now();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
      valueListenable: db.Store.tick,
      builder: (context, snapshots) => FutureBuilder<List<db.Row>>(
          future: db.Store.meals(day),
          builder: (c, s) {
            final ms = s.data ?? [];
            double sum(String k) => ms.fold(
                0.0, (a, m) => a + ((m[k] as num?) ?? 0));
            final pl = db.Store.plan();
            final eaten = sum('kcal');
            final left = (pl['kcal']! - eaten).round();
            final monday =
                day.subtract(Duration(days: day.weekday - 1));
            return ListView(
                padding: const EdgeInsets.all(16),
                children: [
              Text(t('hello'),
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              card(
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
    children: [
                          Text(t('daily'),
                              style:
                                  const TextStyle(fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                              '${eaten.round()} / ${pl['kcal']!.round()} kcal',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ])),
                    SizedBox(
                        width: 76,
                        height: 76,
                        child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                  child: CircularProgressIndicator(
                                      value: (eaten / pl['kcal']!)
                                          .clamp(0, 1)
                                          .toDouble(),
                                      strokeWidth: 9,
                                      color: kGreen,
                                      backgroundColor: Colors.white)),
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$left',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold)),
                                    Text(t('left'),
                                        style: const TextStyle(
                                            fontSize: 8)),
                                  ]),
                            ])),
                  ]),
                  color: kLime),
              Row(children: [
                _macro('protein', sum('protein'), pl['p']!),
                const SizedBox(width: 8),
                _macro('fat', sum('fat'), pl['f']!),
                const SizedBox(width: 8),
                _macro('carbs', sum('carbs'), pl['c']!),
              ]),
              const SizedBox(height: 12),
              card(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (k) {
                    final d = monday.add(Duration(days: k));
                    final sel =
                        d.day == day.day && d.month == day.month;
                    return GestureDetector(
                        onTap: () => setState(() => day = d),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 9),
                            decoration: BoxDecoration(
                                color: sel ? kLime : null,
                                borderRadius:
                                    BorderRadius.circular(20)),
                            child: Column(children: [
                              Text(dn(d.weekday),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('${d.day}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ])));
                  }))),
              Text(t('meals'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
 if (ms.isEmpty)
                card(Text(t('empty'),
                    style: const TextStyle(color: Colors.grey))),
              for (final m in ms)
                card(Row(children: [
                  if (m['photo'] != null &&
                      File(m['photo'] as String).existsSync())
                    Padding(
                        padding:
                            const EdgeInsetsDirectional.only(end: 12),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                                File(m['photo'] as String),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover))),
                  Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Text(
                            '${t(m['type'] as String)} · ${m['name']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Text(
                            '${(m['kcal'] as num).round()} kcal · P ${(m['protein'] as num).round()} · F ${(m['fat'] as num).round()} · C ${(m['carbs'] as num).round()}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                      ])),
                  IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          db.Store.delMeal(m['id'] as int)),
                ])),
            ]);
          }));

  Widget _macro(String k, double v, double goal) => Expanded(
      child: card(
          Column(children: [
            Text(t(k), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('${v.round()} / ${goal.round()} g',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
                value: (v / goal).clamp(0, 1).toDouble(),
                color: kGreen,
                backgroundColor: kLime),
          ]),
          ));
}
 // ---------------- Progress ----------------
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});
  @override
  State<ProgressPage> createState() => _ProgressState();
}

class _ProgressState extends State<ProgressPage> {
  int days = 7;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
      valueListenable: db.Store.tick,
      builder: (_, , _) => FutureBuilder<List<Object>>(
          future: Future.wait([
            db.Store.dailyKcal(days),
            db.Store.weights()
          ]),
          builder: (c, s) {
            final data = s.data?[0] as List<double>? ??
                List.filled(days, 0.0);
            final ws = (s.data?[1] as List<db.Row>?) ?? [];
            final target = db.Store.plan()['kcal']!;
            final today = DateTime.now();

            return ListView(
                padding: const EdgeInsets.all(16),
                children: [
              Row(children: [
                ChoiceChip(
                    label: Text(t('week')),
                    selected: days == 7,
                    onSelected: (_) => setState(() => days = 7)),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: Text(t('month')),
                    selected: days == 30,
                    onSelected: (_) => setState(() => days = 30)),
              ]),
              const SizedBox(height: 12),
              card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('kcal'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(
                        '${data.last.round()} kcal   ${t('target')}: ${target.round()}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                        height: 190,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < data.length; i++)
                                Expanded(
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 1.5),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  height: 150 *
                                                      (data[i] / target)
                                                          .clamp(0.02, 1.2) /
                                                      1.2,
                                                  decoration: BoxDecoration(
                                                      color: i ==
                                                              data.length - 1
                                                          ? kGreen
                                                          : kLime,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(6))),
                                              if (days == 7)
                                                Padding(
padding:
                                                        const EdgeInsets.only(
                                                            top: 6),
                                                    child: Text(
                                                        dn(today
                                                            .subtract(Duration(
                                                                days: data
                                                                        .length -
                                                                    1 -
                                                                    i))
                                                            .weekday),
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.grey))),
                                            ]))),
                            ])),
                  ])),
              Row(children: [
                Expanded(
                    child: Text(t('weight'),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                TextButton.icon(
                    onPressed: _addWeight,
                    icon: const Icon(Icons.add),
                    label: Text(t('add_weight'))),
              ]),
              for (final w in ws.take(10))
                card(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateTime.fromMillisecondsSinceEpoch(
                              w['ts'] as int)
                          .toString()
                          .substring(0, 10)),
                      Text(
                          '${(w['kg'] as num).toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ])),
            ]);
          }));

  void _addWeight() {
    final c = TextEditingController();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(t('add_weight')),
              content: TextField(
                  controller: c,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('cancel'))),
                FilledButton(
                    onPressed: () {
                      final v = _n(c.text);
                      if (v > 0) db.Store.addWeight(v);
                      Navigator.pop(context);
                    },
                    child: Text(t('save'))),
              ],
            ));
  }
}

// ---------------- Add meal ----------------
class AddMeal extends StatefulWidget {
  const AddMeal({super.key});
  @override
  State<AddMeal> createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> {
  String type = 'breakfast';
  String? photo;

  final c = {
    for (final k in ['name', 'kcal', 'protein', 'fat', 'carbs'])
      k: TextEditingController()
  };

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 80);

    if (x == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dest =
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    await File(x.path).copy(dest);
    setState(() => photo = dest);
  }
 @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(t('add_meal'),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          for (final k in ['breakfast', 'lunch', 'dinner', 'snack'])
            ChoiceChip(
                label: Text(t(k)),
                selected: type == k,
                onSelected: (_) => setState(() => type = k)),
        ]),
        TextField(
            controller: c['name'],
            decoration: InputDecoration(labelText: t('name'))),
        Row(children: [
          for (final k in ['kcal', 'protein', 'fat', 'carbs'])
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TextField(
                        controller: c[k],
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration:
                            InputDecoration(labelText: t(k))))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(t('photo'))),
          if (photo != null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Image.file(File(photo!), width: 48, height: 48)),
          const Spacer(),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kGreen),
              onPressed: () async {
                await db.Store.addMeal({
                  'ts': DateTime.now().millisecondsSinceEpoch,
                  'type': type,
                  'name': c['name']!.text,
                  'kcal': _n(c['kcal']!.text),
                  'protein': _n(c['protein']!.text),
                  'fat': _n(c['fat']!.text),
                  'carbs': _n(c['carbs']!.text),
                  'photo': photo,
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(t('save'))),
        ]),
      ])));
}
 // ---------------- Menu ----------------
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuState();
}

class _MenuState extends State<MenuPage> {
  late String sex = db.Store.profile['sex'] ?? 'm';
  late String act = db.Store.profile['act'] ?? 'mid';

  late final age = TextEditingController(
      text: '${db.Store.profile['age'] ?? ''}');
  late final height = TextEditingController(
      text: '${db.Store.profile['height'] ?? ''}');
  late final weight = TextEditingController(
      text: '${db.Store.profile['weight'] ?? ''}');
  late final target = TextEditingController(
      text: '${db.Store.profile['target'] ?? ''}');

  void _snack(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final pl = db.Store.plan();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('language'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'ar', label: Text('العربية')),
          ],
          selected: {db.Store.lang.value},
          onSelectionChanged: (s) => db.Store.setLang(s.first),
        ),

        const SizedBox(height: 16),

        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('profile'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),

              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'm', label: Text(t('male'))),
                  ButtonSegment(
                      value: 'f', label: Text(t('female'))),
                ],
                selected: {sex},
                onSelectionChanged: (s) =>
                    setState(() => sex = s.first),
              ),

              _f(age, 'age'),
              _f(height, 'height'),
              _f(weight, 'cur_weight'),
              _f(target, 'target_weight'),

              const SizedBox(height: 8),

              SegmentedButton<String>(
                segments: [
                  for (final k in ['low', 'mid', 'high'])
                    ButtonSegment(value: k, label: Text(t(k))),
                ],
                selected: {act},
                onSelectionChanged: (s) =>
                    setState(() => act = s.first),
              ),

              const SizedBox(height: 12),

              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: kGreen),
                onPressed: () async {
                  if (_n(age.text) <= 0 ||
                      _n(height.text) <= 0 ||
                      _n(weight.text) <= 0) {
                    _snack(t('bad'));
                    return;
                  }

                  await db.Store.saveProfile({
                    'sex': sex,
                    'act': act,
                    'age': _n(age.text),
                    'height': _n(height.text),
                    'weight': _n(weight.text),
                    if (_n(target.text) > 0)
                      'target': _n(target.text),
                  });

                  if (!mounted) return;
                  setState(() {});
                  _snack(t('saved'));
                },
                child: Text(t('save')),
              ),
            ],
          ),
        ),

        if (db.Store.profile.isNotEmpty)
 card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${t('ideal')}: ${pl['ideal']!.toStringAsFixed(1)} kg'),
                Text(
                    '${t('goal_kcal')}: ${pl['kcal']!.round()} kcal'),
                Text(
                    '${t('protein')}: ${pl['p']!.round()} g · ${t('fat')}: ${pl['f']!.round()} g · ${t('carbs')}: ${pl['c']!.round()} g'),
                const SizedBox(height: 8),
                Text(
                  t('disclaimer'),
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            color: kLime,
          ),

        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('backup'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                            text: await db.Store.exportJson()),
                      );
                      if (mounted) _snack(t('copied'));
                    },
                    child: Text(t('export')),
                  ),

                  OutlinedButton(
                    onPressed: () async {
                      final d =
                          await Clipboard.getData('text/plain');

                      final ok = await db.Store.importJson(
                          d?.text ?? '');

                      if (!mounted) return;
                      setState(() {});
                      _snack(ok ? t('imported') : t('bad'));
                    },
                    child: Text(t('import')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _f(TextEditingController c, String k) => TextField(
        controller: c,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: t(k)),
      );
}
