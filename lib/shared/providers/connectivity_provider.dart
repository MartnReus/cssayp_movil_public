import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

enum ConnectivityStatus { online, offline }

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityNotifier() : super(ConnectivityStatus.offline) {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (hasConnection) {
        final hasInternet = await _checkInternetConnection();
        state = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
      } else {
        state = ConnectivityStatus.offline;
      }
    });
    _checkInitialConnection();
  }

  void _checkInitialConnection() async {
    final hasInternet = await _checkInternetConnection();
    state = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
