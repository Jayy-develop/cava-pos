import 'dart:async';
import 'package:flutter/foundation.dart';

enum SyncStatus { synced, syncing, pending, offline }

class CloudSyncService extends ChangeNotifier {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;

  CloudSyncService._internal() {
    _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 2));
  }

  bool _isOnline = true;
  bool _isSyncing = false;
  int _pendingOrdersCount = 0;
  DateTime _lastSyncTime = DateTime.now();
  String _databaseProvider = 'Supabase PostgreSQL Cloud';
  String _databaseEndpoint = 'https://cava-pos-db.supabase.co';

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingOrdersCount => _pendingOrdersCount;
  DateTime get lastSyncTime => _lastSyncTime;
  String get databaseProvider => _databaseProvider;
  String get databaseEndpoint => _databaseEndpoint;

  SyncStatus get status {
    if (!_isOnline) return SyncStatus.offline;
    if (_isSyncing) return SyncStatus.syncing;
    if (_pendingOrdersCount > 0) return SyncStatus.pending;
    return SyncStatus.synced;
  }

  /// Toggle simulated internet connectivity (Online vs Offline mode)
  void toggleConnectivity() {
    _isOnline = !_isOnline;
    if (_isOnline && _pendingOrdersCount > 0) {
      // Automatically drain queue when back online
      syncNow();
    } else {
      notifyListeners();
    }
  }

  /// Record an order saved into local database while offline
  void recordOfflineTransaction(String orderId) {
    if (!_isOnline) {
      _pendingOrdersCount++;
      notifyListeners();
    } else {
      _lastSyncTime = DateTime.now();
      notifyListeners();
    }
  }

  /// Push all queued offline transactions to remote Cloud DB
  Future<void> syncNow() async {
    if (!_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    // Simulate network round-trip to Cloud Postgres / REST API
    await Future.delayed(const Duration(milliseconds: 1200));

    _pendingOrdersCount = 0;
    _isSyncing = false;
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  void updateEndpoint({required String provider, required String endpoint}) {
    _databaseProvider = provider;
    _databaseEndpoint = endpoint;
    notifyListeners();
  }
}
