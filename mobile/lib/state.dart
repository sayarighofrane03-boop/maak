import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AppState extends ChangeNotifier {
  Map<String, dynamic>? user;
  Map<String, dynamic>? profile;
  List tutors = [], bookings = [], messages = [], notifs = [];
  Timer? _poll;
  String locale = 'ar';
  bool get isTutor => user?['role'] == 'tutor';
  int get unread => notifs.where((n) => n['read_at'] == null).length;

  Future<void> init() async {
    locale = (await SharedPreferences.getInstance()).getString('locale') ?? 'ar';
    if (!['ar', 'fr', 'en'].contains(locale)) locale = 'ar';
    await Api.loadToken();
    if (Api.token != null) {
      try {
        await _boot();
      } catch (_) {
        await Api.saveToken(null);
      }

      Future<void> setLocale(String value) async {
        if (!['ar', 'fr', 'en'].contains(value) || locale == value) return;
        locale = value;
        await (await SharedPreferences.getInstance()).setString('locale', value);
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> _boot() async {
    final me = await Api.call('GET', '/me');
    user = me;
    profile = me['profile'];
    await refresh();
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        await refresh();
      } catch (_) {}
    });
  }

  Future<void> refresh() async {
    tutors = await Api.call('GET', '/tutors');
    bookings = await Api.call('GET', '/bookings');
    messages = await Api.call('GET', '/messages');
    notifs = await Api.call('GET', '/notifications');
    notifyListeners();
  }

  Future<void> auth(bool register, Map<String, dynamic> body) async {
    final r = await Api.call('POST', register ? '/auth/register' : '/auth/login', body);
    await Api.saveToken(r['token']);
    await _boot();
    notifyListeners();
  }

  Future<void> markRead() async {
    await Api.call('POST', '/notifications/read');
    await refresh();
  }

  Future<void> logout() async {
    _poll?.cancel();
    await Api.saveToken(null);
    user = null;
    profile = null;
    tutors = [];
    bookings = [];
    messages = [];
    notifs = [];
    notifyListeners();
  }

  Future<void> book(int tutorId, String slot, String mode, {String? subject}) async {
    await Api.call('POST', '/bookings', {'tutor_id': tutorId, 'slot': slot, 'mode': mode, if (subject != null) 'subject': subject});
    await refresh();
  }

  Future<void> setStatus(int id, String status) async {
    await Api.call('PATCH', '/bookings/$id', {'status': status});
    await refresh();
  }

  Future<void> send(int to, String body) async {
    await Api.call('POST', '/messages', {'to': to, 'body': body});
    await refresh();
  }

  Future<void> review(int bookingId, int rating, String comment) async {
    await Api.call('POST', '/reviews', {'booking_id': bookingId, 'rating': rating, 'comment': comment});
    await refresh();
  }

  Future<void> saveProfile(Map<String, dynamic> body) async {
    await Api.call('PUT', '/tutor/profile', body);
    final me = await Api.call('GET', '/me');
    profile = me['profile'];
    notifyListeners();
  }
}

final app = AppState();
