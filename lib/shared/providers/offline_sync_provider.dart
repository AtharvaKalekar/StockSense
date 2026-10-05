import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/offline_queue_model.dart';

class OfflineModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.keySimulateOffline) ?? false;
  }

  Future<void> toggleOffline(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySimulateOffline, value);
  }
}

final isOfflineSimulatedProvider = NotifierProvider<OfflineModeNotifier, bool>(OfflineModeNotifier.new);
final offlineSimulationProvider = isOfflineSimulatedProvider;

class OfflineQueueNotifier extends Notifier<List<OfflineQueueItem>> {
  @override
  List<OfflineQueueItem> build() {
    _loadQueue();
    return [];
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyOfflineQueue) ?? [];
    state = raw.map((item) => OfflineQueueItem.fromJson(jsonDecode(item))).toList();
  }

  Future<void> addItem(OfflineQueueItem item) async {
    state = [...state, item];
    await _saveQueue();
  }

  Future<void> clearQueue() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyOfflineQueue);
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(AppConstants.keyOfflineQueue, rawList);
  }
}

final offlineQueueProvider = NotifierProvider<OfflineQueueNotifier, List<OfflineQueueItem>>(OfflineQueueNotifier.new);
