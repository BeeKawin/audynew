import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/caretaker_repository.dart';
import '../services/auth_service.dart';

class CaretakerController extends ChangeNotifier {
  CaretakerController(this.accountId, this.repository);
  final String accountId;
  final CaretakerRepository repository;
  CaretakerRoster? roster;
  String? selectedId;
  String? error;
  bool loading = false;
  bool _disposed = false;
  int _request = 0;
  List<UserProfile> get children =>
      roster?.children.where((c) => c.inCare).map((c) => c.profile).toList() ??
      [];
  UserProfile? get selected {
    for (final child in children) {
      if (child.id == selectedId) return child;
    }
    return null;
  }

  Future<void> load() async {
    final request = ++_request;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await repository.load();
      final prefs = await SharedPreferences.getInstance();
      if (_disposed || request != _request) return;
      roster = data;
      final previous =
          selectedId ?? prefs.getString('caretaker.selected_child.$accountId');
      selectedId = children.any((c) => c.id == previous)
          ? previous
          : children.firstOrNull?.id;
    } catch (e) {
      if (!_disposed && request == _request) error = caretakerError(e);
    } finally {
      if (!_disposed && request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> select(String id) async {
    if (!children.any((c) => c.id == id)) return;
    selectedId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (!_disposed) {
      await prefs.setString('caretaker.selected_child.$accountId', id);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    super.dispose();
  }
}
