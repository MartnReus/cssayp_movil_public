import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

enum ConnectivityStatus { online, offline }

final connectivityProvider = StreamNotifierProvider<ConnectivityNotifier, ConnectivityStatus>(ConnectivityNotifier.new);

class ConnectivityNotifier extends StreamNotifier<ConnectivityStatus> {
  @override
  Stream<ConnectivityStatus> build() {
    final connectivityStream = Connectivity().onConnectivityChanged;
    return connectivityStream.asyncMap((result) async {
      if (result.contains(ConnectivityResult.none)) {
        return ConnectivityStatus.offline;
      }

      final hasInternet = await _checkInternetConnection();
      return hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
