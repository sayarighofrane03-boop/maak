import 'package:flutter/material.dart';
import 'api.dart';
import 'state.dart';
import 'i18n.dart';

const matieres = ['Maths', 'Physique', 'SVT', 'Français', 'Arabe', 'Anglais', 'Informatique', 'Éco-gestion', 'Philo', 'Theatre'];
const villes = ['Tunis', 'Ariana', 'Sfax', 'Sousse', 'Bizerte', 'Nabeul'];
const matiereAr = {'Maths': 'الرياضيات', 'Physique': 'الفيزياء', 'SVT': 'علوم الحياة والأرض', 'Français': 'الفرنسية', 'Arabe': 'العربية', 'Anglais': 'الإنجليزية', 'Informatique': 'الإعلامية', 'Éco-gestion': 'الاقتصاد والتصرّف', 'Philo': 'الفلسفة', 'Theatre': 'المسرح'};
const villeAr = {'Tunis': 'تونس', 'Ariana': 'أريانة', 'Sfax': 'صفاقس', 'Sousse': 'سوسة', 'Bizerte': 'بنزرت', 'Nabeul': 'نابل'};
const niveauApi = {'الكل': null, 'ابتدائي': 'Primaire', 'إعدادي': 'Collège', 'ثانوي': 'Lycée', 'باكالوريا': 'Bac', 'جميع الأعمار': 'جميع الأعمار'};
const bold = TextStyle(fontWeight: FontWeight.bold);

String subjectLabel(String value) => translate(matiereAr[value] ?? value, app.locale);
String cityLabel(dynamic value) => translate(villeAr[value] ?? (value == null ? 'يُحدّد لاحقًا' : '$value'), app.locale);
String modeLabel(String value) => translate({'En ligne': 'عن بُعد', 'À domicile': 'في المنزل', 'Lieu public': 'مكان عام'}[value] ?? value, app.locale);
Widget tutorAvatar(Map tutor, {double radius = 25}) {
  final isGhofrane = tutor['n'] == 'Ghofrane Sayari';
  final initials = (tutor['n'] as String).split(' ').where((part) => part.isNotEmpty).map((part) => part[0]).join();
  return CircleAvatar(
    radius: radius,
    backgroundColor: isGhofrane ? const Color(0xFFC45C43) : const Color(0xFF176B5D),
    foregroundColor: Colors.white,
    child: Text(isGhofrane ? 'GS' : initials, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

Widget archBanner(String title, String subtitle) => ClipPath(
      clipper: _TunisianArchClipper(),
      child: Container(
        constraints: const BoxConstraints(minHeight: 142),
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        decoration: const BoxDecoration(color: Color(0xFF123F3A)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Color(0xFFE5D9C1), fontSize: 14)),
          ])),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD9A441), width: 2), borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
            child: const Icon(Icons.architecture, color: Color(0xFFD9A441), size: 28),
          ),
        ]),
      ),
    );

class _TunisianArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height)
    ..lineTo(0, size.height * .38)
    ..quadraticBezierTo(0, 0, size.width * .5, 0)
    ..quadraticBezierTo(size.width, 0, size.width, size.height * .38)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

InputDecoration deco(String l, {IconData? icon}) => InputDecoration(
      labelText: translate(l, app.locale),
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE4DF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF176B5D), width: 1.5)),
    );
void toast(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(translate(m, app.locale))));
Widget live(Widget Function() b) => ListenableBuilder(listenable: app, builder: (_, __) => b());
String tutorName(dynamic id) => '${app.tutors.firstWhere((t) => t['id'] == id, orElse: () => {'n': translate('مدرّس', app.locale)})['n']}';

Future<void> guard(BuildContext c, Future<void> Function() f, [String? ok]) async {
  try {
    await f();
    if (ok != null && c.mounted) toast(c, ok);
  } catch (e) {
    if (c.mounted) toast(c, '$e');
  }
}

// ───────────── تسجيل الدخول ─────────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  bool reg = false, busy = false;
  String role = 'student', city = 'Tunis';
  final em = TextEditingController(), pw = TextEditingController(), nm = TextEditingController();

  Future<void> go() async {
    setState(() => busy = true);
    await guard(context, () => app.auth(reg, {'email': em.text.trim(), 'password': pw.text, if (reg) ...{'name': nm.text.trim(), 'role': role, 'city': city}}));
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [const LanguagePicker()]),
            archBanner(translate('MAAK · تونس', app.locale), translate('دعم دراسي قريب منك', app.locale)),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: [ButtonSegment(value: false, label: Text(translate('دخول', app.locale))), ButtonSegment(value: true, label: Text(translate('حساب جديد', app.locale)))],
              selected: {reg},
              onSelectionChanged: (s) => setState(() => reg = s.first),
            ),
            const SizedBox(height: 16),
            if (reg) ...[
              TextField(controller: nm, decoration: deco('الاسم الكامل')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                decoration: deco('نوع الحساب'),
                items: [DropdownMenuItem(value: 'student', child: Text(translate('تلميذ أو تلميذة', app.locale))), DropdownMenuItem(value: 'tutor', child: Text(translate('مدرّس أو مدرّسة', app.locale)))],
                onChanged: (v) => setState(() => role = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: city,
                decoration: deco('المدينة'),
                items: [for (final v in villes) DropdownMenuItem(value: v, child: Text(cityLabel(v)))],
                onChanged: (v) => setState(() => city = v!),
              ),
              const SizedBox(height: 12),
            ],
            TextField(controller: em, keyboardType: TextInputType.emailAddress, decoration: deco('البريد الإلكتروني')),
            const SizedBox(height: 12),
            TextField(controller: pw, obscureText: true, decoration: deco('كلمة المرور (6 أحرف على الأقل)')),
            const SizedBox(height: 20),
            FilledButton(onPressed: busy ? null : go, child: Text(busy ? '...' : translate(reg ? 'إنشاء الحساب' : 'دخول', app.locale))),
          ]),
        ),
      );
}

// ───────────── فضاء التلميذ ─────────────
Widget bell() => Badge.count(count: app.unread, isLabelVisible: app.unread > 0, child: const Icon(Icons.notifications_outlined));

class Shell extends StatefulWidget {
  final List<Widget> pages;
  final List<(IconData, String)> tabs;
  const Shell(this.pages, this.tabs, {super.key});
  @override
  State<Shell> createState() => _Sh();
}

class _Sh extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext c) => Scaffold(
        body: SafeArea(child: widget.pages[i]),
        bottomNavigationBar: live(() => NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (v) => setState(() => i = v),
              destinations: [for (final t in widget.tabs) NavigationDestination(icon: t.$1 == Icons.notifications_outlined ? bell() : Icon(t.$1), label: t.$2)],
            )),
      );
}

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});
  @override
  Widget build(BuildContext c) => Shell(
        const [ExploreTab(), BookingsTab(), MessagesTab(), NotificationsTab(), ProfileTab()],
        [(Icons.search, translate('استكشاف', app.locale)), (Icons.event, translate('حصصي', app.locale)), (Icons.chat_bubble_outline, translate('الرسائل', app.locale)), (Icons.notifications_outlined, translate('تنبيهات', app.locale)), (Icons.person_outline, translate('حسابي', app.locale))],
      );
}

class TutorShell extends StatelessWidget {
  const TutorShell({super.key});
  @override
  Widget build(BuildContext c) => Shell(
        const [RequestsTab(), MessagesTab(), NotificationsTab(), TutorProfileTab()],
        [(Icons.inbox_outlined, translate('الطلبات', app.locale)), (Icons.chat_bubble_outline, translate('الرسائل', app.locale)), (Icons.notifications_outlined, translate('تنبيهات', app.locale)), (Icons.person_outline, translate('حسابي', app.locale))],
      );
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});
  @override
  Widget build(BuildContext c) => live(() => RefreshIndicator(
        onRefresh: app.refresh,
        child: ListView(children: [
          if (app.notifs.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Text(translate('لا توجد تنبيهات.', app.locale))),
          if (app.unread > 0) TextButton(onPressed: () => guard(c, app.markRead), child: Text(translate('تحديد الكل كمقروء', app.locale))),
          for (final n in app.notifs)
            ListTile(
              leading: Icon(n['read_at'] == null ? Icons.circle : Icons.circle_outlined, size: 12),
              title: Text('${n['body']}'),
              subtitle: Text('${n['created_at']}'),
            ),
        ]),
      ));
}

String partnerName(dynamic id) {
  for (final m in app.messages) {
    if (m['sender_id'] == id) return '${m['sender_name']}';
    if (m['receiver_id'] == id) return '${m['receiver_name']}';
  }
  return tutorName(id);
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});
  @override
  State<ExploreTab> createState() => _ET();
}

class _ET extends State<ExploreTab> {
  String q = '', mat = 'الكل', ville = 'الكل', niveau = 'الكل';
  @override
  Widget build(BuildContext c) => live(() {
        final L = app.tutors.where((t) {
          final ms = (t['m'] as List).cast<String>();
          final levels = (t['l'] as List).cast<String>();
          final selectedLevel = niveauApi[niveau];
          final searchable = '${t['n']} ${t['u']} ${t['b']} ${ms.join(' ')} ${ms.map(subjectLabel).join(' ')} ${cityLabel(t['c'])}'.toLowerCase();
          return (mat == 'الكل' || ms.contains(mat)) &&
              (ville == 'الكل' || t['c'] == ville) &&
              (selectedLevel == null || levels.contains(selectedLevel)) &&
              (q.isEmpty || searchable.contains(q.toLowerCase()));
        }).toList();
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 12), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [const LanguagePicker()]), archBanner(translate('تعلّم بثقة', app.locale), translate('اختر المدرّس المناسب لك', app.locale))])),
          Expanded(
            child: RefreshIndicator(
              onRefresh: app.refresh,
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), children: [
                TextField(onChanged: (v) => setState(() => q = v), decoration: deco('ابحث بالاسم أو المادة', icon: Icons.search)),
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, constraints) {
                  final width = (constraints.maxWidth - 10) / 2;
                  return Wrap(spacing: 10, runSpacing: 10, children: [
                    SizedBox(width: width, child: DropdownButtonFormField<String>(
                      value: ville,
                      isExpanded: true,
                      decoration: deco('المدينة'),
                      items: [DropdownMenuItem(value: 'الكل', child: Text(translate('كلّ المدن', app.locale))), for (final v in villes) DropdownMenuItem(value: v, child: Text(cityLabel(v)))],
                      onChanged: (v) => setState(() => ville = v!),
                    )),
                    SizedBox(width: width, child: DropdownButtonFormField<String>(
                      value: niveau,
                      isExpanded: true,
                      decoration: deco('الفئة العمرية'),
                      items: [for (final v in niveauApi.keys) DropdownMenuItem(value: v, child: Text(v == 'الكل' ? translate(v, app.locale) : levelLabel(v, app.locale)))],
                      onChanged: (v) => setState(() => niveau = v!),
                    )),
                  ]);
                }),
                const SizedBox(height: 10),
                SizedBox(height: 42, child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [for (final m in ['الكل', ...matieres])
                    Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: ChoiceChip(
                      label: Text(m == 'الكل' ? m : subjectLabel(m)),
                      selected: mat == m,
                      onSelected: (_) => setState(() => mat = m),
                    )),
                  ],
                )),
                const SizedBox(height: 8),
                if (L.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(translate('لا يوجد مدرّسون مطابقون للبحث.', app.locale)))),
                for (final t in L) TutorCard(t),
              ]),
            ),
          ),
        ]);
      });
}

class TutorCard extends StatelessWidget {
  final Map t;
  const TutorCard(this.t, {super.key});
  @override
  Widget build(BuildContext c) {
    final openProfile = () => Navigator.push(c, MaterialPageRoute(builder: (_) => TutorDetail(t)));
    final ratingCount = (t['rv'] as num?)?.toInt() ?? 0;
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x1F123F3A),
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        tutorAvatar(t),
        const SizedBox(width: 12),
        Expanded(child: Text('${t['n']}', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 8),
      Text('${t['u']}', style: Theme.of(c).textTheme.bodyMedium),
      const SizedBox(height: 8),
      Text(app.locale == 'ar' ? '${t['p']} د.ت / الساعة' : app.locale == 'fr' ? '${t['p']} DT / heure' : '${t['p']} TND / hour', style: Theme.of(c).textTheme.titleSmall?.copyWith(color: const Color(0xFF176B5D), fontWeight: FontWeight.w800)),
      Text(cityLabel(t['c']), style: Theme.of(c).textTheme.bodySmall),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 2, children: [for (final subject in (t['m'] as List).cast<String>()) Chip(label: Text(subjectLabel(subject)), visualDensity: VisualDensity.compact)]),
      if (ratingCount > 0) Text('★ ${(t['r'] as num).toStringAsFixed(1)} · $ratingCount ${translate('تقييم', app.locale)}'),
      if (ratingCount == 0) Text(translate('مدرّسة جديدة', app.locale), style: const TextStyle(color: Color(0xFFC45C43))),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: openProfile, icon: const Icon(Icons.event_available_outlined), label: const Text('احجز حصة'))),
      ])),
    );
  }
}

class TutorDetail extends StatefulWidget {
  final Map t;
  const TutorDetail(this.t, {super.key});
  @override
  State<TutorDetail> createState() => _TD();
}

class _TD extends State<TutorDetail> {
  String? slot, mode;
  late final Future<dynamic> revs = Api.call('GET', '/tutors/${widget.t['id']}/reviews');

  @override
  Widget build(BuildContext c) {
    final t = widget.t;
    return Scaffold(
      appBar: AppBar(title: Text('${t['n']}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [tutorAvatar(t, radius: 30), const SizedBox(width: 12), Expanded(child: Text('${t['n']}', style: Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 12),
          Text('${t['u']}', style: Theme.of(c).textTheme.titleSmall),
          Text(cityLabel(t['c'])),
          const SizedBox(height: 6),
          Text(app.locale == 'ar' ? '${t['p']} د.ت / الساعة' : app.locale == 'fr' ? '${t['p']} DT / heure' : '${t['p']} TND / hour', style: Theme.of(c).textTheme.titleMedium?.copyWith(color: const Color(0xFF176B5D), fontWeight: FontWeight.w800)),
          Text((t['l'] as List).map((level) => levelLabel('$level', app.locale)).join(app.locale == 'ar' ? '، ' : ', ')),
        ]))),
        const SizedBox(height: 8),
        Directionality(textDirection: TextDirection.ltr, child: Text('${t['b']}', textAlign: TextAlign.left)),
        const SizedBox(height: 16),
        Text(translate('اختر موعدًا', app.locale), style: bold),
        Wrap(spacing: 8, children: [for (final s in (t['s'] as List).cast<String>()) ChoiceChip(label: Text(s), selected: slot == s, onSelected: (_) => setState(() => slot = s))]),
        const SizedBox(height: 12),
        Text(translate('طريقة الحصة', app.locale), style: bold),
        Wrap(spacing: 8, children: [for (final s in (t['md'] as List).cast<String>()) ChoiceChip(label: Text(modeLabel(s)), selected: mode == s, onSelected: (_) => setState(() => mode = s))]),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: slot == null || mode == null
              ? null
              : () => guard(c, () async {
                    final subjects = (t['m'] as List).cast<String>();
                    await app.book(t['id'], slot!, mode!, subject: subjects.length == 1 ? subjects.single : null);
                    if (c.mounted) {
                      toast(c, 'تم إرسال طلب الحصة إلى المدرّس');
                      Navigator.pop(c);
                    }
                  }),
          icon: const Icon(Icons.event_available_outlined),
          label: Text(translate('احجز حصة', app.locale)),
        ),
        OutlinedButton.icon(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ChatScreen(t['id'], '${t['n']}'))), icon: const Icon(Icons.chat_bubble_outline), label: Text(translate('راسل المدرّس', app.locale))),
        FutureBuilder(
          future: revs,
          builder: (_, s) {
            final L = (s.data as List?) ?? [];
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(height: 32),
              Text('${translate('التقييمات', app.locale)} (${L.length})', style: bold),
              for (final v in L) ListTile(dense: true, title: Text('★ ${v['rating']} · ${v['student']}'), subtitle: Text('${v['comment'] ?? ''}')),
            ]);
          },
        ),
      ]),
    );
  }
}

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});
  @override
  Widget build(BuildContext c) => live(() => RefreshIndicator(
        onRefresh: app.refresh,
        child: ListView(padding: const EdgeInsets.all(12), children: [
          if (app.bookings.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Text(translate('لا توجد حصص بعد.', app.locale))),
          for (final b in app.bookings)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text(tutorName(b['tutor_id']), style: bold)), Chip(label: Text(statusLabel('${b['status']}', app.locale)))]),
                  Text('${b['slot']} · ${modeLabel('${b['mode']}')}'),
                  Row(children: [
                    if (b['status'] == 'pending' || b['status'] == 'confirmed') TextButton(onPressed: () => guard(c, () => app.setStatus(b['id'], 'cancelled')), child: Text(translate('إلغاء', app.locale))),
                    if (b['status'] == 'done' && b['rated'] == null) FilledButton.tonal(onPressed: () => rateDialog(c, b['id']), child: Text(translate('أضف تقييمًا', app.locale))),
                  ]),
                ]),
              ),
            ),
        ]),
      ));
}

Future<void> rateDialog(BuildContext c, int bookingId) async {
  int n = 5;
  final tc = TextEditingController();
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: Text(translate('تقييم الحصة', app.locale)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (var i = 1; i <= 5; i++) IconButton(icon: Icon(i <= n ? Icons.star : Icons.star_border), onPressed: () => set(() => n = i))]),
          TextField(controller: tc, decoration: deco('تعليق')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(translate('إغلاق', app.locale))),
          FilledButton(
            onPressed: () async {
              Navigator.pop(d);
              await guard(c, () => app.review(bookingId, n, tc.text), 'شكرًا على تقييمك');
            },
            child: Text(translate('إرسال', app.locale)),
          ),
        ],
      ),
    ),
  );
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});
  @override
  Widget build(BuildContext c) => live(() {
        final me = app.user!['id'];
        final ids = <dynamic>{};
        for (final m in app.messages.reversed) {
          ids.add(m['sender_id'] == me ? m['receiver_id'] : m['sender_id']);
        }
        if (ids.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(translate('لا توجد محادثات بعد.', app.locale))));
        return ListView(children: [
          for (final id in ids)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(partnerName(id)),
              onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ChatScreen(id, partnerName(id)))),
            ),
        ]);
      });
}

class ChatScreen extends StatefulWidget {
  final int to;
  final String name;
  const ChatScreen(this.to, this.name, {super.key});
  @override
  State<ChatScreen> createState() => _CS();
}

class _CS extends State<ChatScreen> {
  final tc = TextEditingController();
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: live(() {
          final me = app.user!['id'];
          final L = app.messages.where((m) => m['sender_id'] == widget.to || m['receiver_id'] == widget.to).toList();
          return Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(12), children: [
                for (final m in L)
                  Align(
                    alignment: m['sender_id'] == me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Card(
                      color: m['sender_id'] == me ? Theme.of(c).colorScheme.primaryContainer : null,
                      child: Padding(padding: const EdgeInsets.all(10), child: Text('${m['body']}')),
                    ),
                  ),
              ]),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Expanded(child: TextField(controller: tc, decoration: deco('اكتب رسالتك'))),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final t = tc.text.trim();
                      if (t.isEmpty) return;
                      tc.clear();
                      await guard(c, () => app.send(widget.to, t));
                    },
                  ),
                ]),
              ),
            ),
          ]);
        }),
      );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext c) => live(() => ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text('${app.user?['name']}'), subtitle: Text('${cityLabel(app.user?['city'])} · ${app.user?['email']}')),
        const SizedBox(height: 16),
        Row(children: [Text(translate('اللغة', app.locale)), const Spacer(), const LanguagePicker()]),
        OutlinedButton(onPressed: app.logout, child: Text(translate('تسجيل الخروج', app.locale))),
      ]));
}

// ───────────── Espace tuteur ─────────────
class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});
  @override
  Widget build(BuildContext c) => live(() {
        final n = app.bookings.where((b) => b['status'] == 'confirmed' || b['status'] == 'done').length;
        final p = (app.profile?['p'] ?? 0) as num;
        return RefreshIndicator(
          onRefresh: app.refresh,
          child: ListView(padding: const EdgeInsets.all(12), children: [
            Card(child: ListTile(title: Text(translate('الأرباح المتوقعة', app.locale)), trailing: Text(app.locale == 'ar' ? '${n * p} د.ت' : app.locale == 'fr' ? '${n * p} DT' : '${n * p} TND', style: bold))),
            for (final b in app.bookings)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text('${b['student_name']}', style: bold)), Chip(label: Text(statusLabel('${b['status']}', app.locale)))]),
                    Text('${b['student_level'] == null ? '' : levelLabel('${b['student_level']}', app.locale)} · ${b['slot']} · ${modeLabel('${b['mode']}')}'),
                    Row(children: [
                      if (b['status'] == 'pending') ...[
                        FilledButton(onPressed: () => guard(c, () => app.setStatus(b['id'], 'confirmed')), child: Text(translate('قبول', app.locale))),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () => guard(c, () => app.setStatus(b['id'], 'declined')), child: Text(translate('رفض', app.locale))),
                      ],
                      if (b['status'] == 'confirmed') FilledButton.tonal(onPressed: () => guard(c, () => app.setStatus(b['id'], 'done')), child: Text(translate('تأكيد إتمام الحصة', app.locale))),
                    ]),
                  ]),
                ),
              ),
          ]),
        );
      });
}

class TutorProfileTab extends StatefulWidget {
  const TutorProfileTab({super.key});
  @override
  State<TutorProfileTab> createState() => _TP();
}

class _TP extends State<TutorProfileTab> {
  late final pc = TextEditingController(text: '${app.profile?['p'] ?? 15}');
  late final bc = TextEditingController(text: '${app.profile?['b'] ?? ''}');
  late final Set<String> mats = {...?(app.profile?['mat'] as List?)?.cast<String>()};
  late bool on = app.profile?['on'] == 1 || app.profile?['on'] == true;
  late final List<String> slots = [...?(app.profile?['slots'] as List?)?.cast<String>()];
  String day = 'Lun', hour = '17h';
  static const days = {'Lun': 'الاثنين', 'Mar': 'الثلاثاء', 'Mer': 'الأربعاء', 'Jeu': 'الخميس', 'Ven': 'الجمعة', 'Sam': 'السبت', 'Dim': 'الأحد'};

  @override
  Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(16), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(translate('ملفي كمدرّس', app.locale), style: Theme.of(c).textTheme.headlineSmall), const LanguagePicker()]),
        const SizedBox(height: 16),
        TextField(controller: pc, keyboardType: TextInputType.number, decoration: deco('الأجر (د.ت / الساعة)')),
        const SizedBox(height: 12),
        TextField(controller: bc, maxLines: 3, decoration: deco('نبذة عنك')),
        const SizedBox(height: 12),
        Text(translate('المواد التي أدرّسها', app.locale), style: bold),
        Wrap(spacing: 8, children: [for (final m in matieres) FilterChip(label: Text(subjectLabel(m)), selected: mats.contains(m), onSelected: (v) => setState(() => v ? mats.add(m) : mats.remove(m)))]),
        const SizedBox(height: 8),
        Text(translate('مواعيدي المتاحة', app.locale), style: bold),
        Wrap(spacing: 8, children: [for (final s in slots) InputChip(label: Text(s), onDeleted: () => setState(() => slots.remove(s)))]),
        Row(children: [
          DropdownButton<String>(value: day, items: [for (final d in days.keys) DropdownMenuItem(value: d, child: Text(translate(days[d]!, app.locale)))], onChanged: (v) => setState(() => day = v!)),
          const SizedBox(width: 12),
          DropdownButton<String>(value: hour, items: [for (var h = 8; h <= 21; h++) DropdownMenuItem(value: '${h}h', child: Text('${h}h'))], onChanged: (v) => setState(() => hour = v!)),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: () {
              final s = '$day $hour';
              if (!slots.contains(s)) setState(() => slots.add(s));
            },
            child: Text(translate('إضافة', app.locale)),
          ),
        ]),
        SwitchListTile(title: Text(translate('متاح لاستقبال طلبات جديدة', app.locale)), value: on, onChanged: (v) => setState(() => on = v)),
        FilledButton(
          onPressed: () {
            final rate = int.tryParse(pc.text);
            if (rate == null || rate < 1) {
              toast(c, 'أدخل أجراً صحيحاً');
              return;
            }
            guard(c, () => app.saveProfile({'hourly_rate': rate, 'bio': bc.text, 'is_available': on, 'subjects': mats.toList(), 'slots': slots}), 'تم حفظ الملف الشخصي');
          },
          child: Text(translate('حفظ الملف الشخصي', app.locale)),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: app.logout, child: Text(translate('تسجيل الخروج', app.locale))),
      ]);
}
