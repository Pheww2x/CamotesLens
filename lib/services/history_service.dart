import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/classification_history.dart';

class HistoryService {
  static const _key = 'classification_history';

  Future<List<ClassificationHistory>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList(_key) ?? [];
    return entries
        .map((entry) => ClassificationHistory.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> add(ClassificationHistory item) async {
    final items = await load();
    items.insert(0, item);
    await _save(items.take(100).toList());
  }

  Future<void> toggleFavorite(String id) async {
    final items = await load();
    await _save(items
        .map((item) =>
            item.id == id ? item.copyWith(isFavorite: !item.isFavorite) : item)
        .toList());
  }

  Future<void> markPendingAsSynced() async {
    final items = await load();
    await _save(items.map((item) => item.copyWith(isSynced: true)).toList());
  }

  Future<void> delete(String id) async {
    final items = await load();
    await _save(items.where((item) => item.id != id).toList());
  }

  Future<void> _save(List<ClassificationHistory> items) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
