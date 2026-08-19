import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:threshold/core/utils/app_logger.dart';

class NetworkMonitor {
  NetworkMonitor() {
    _initInitialState();
    _connectivity.onConnectivityChanged.listen((event) {
      final next = _getDominantResult(event);
      _currentStatus = next;
      _controller.add(next);
      logger.i('Connectivity changed: $next');
    });
  }

  ConnectivityResult _currentStatus = ConnectivityResult.none;

  Future<void> _initInitialState() async {
    final result = await _connectivity.checkConnectivity();
    _currentStatus = _getDominantResult(result);
    _controller.add(_currentStatus);
    logger.i('Initial connectivity: $_currentStatus');
  }

  ConnectivityResult _getDominantResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityResult.none;
    if (results.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (results.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    if (results.contains(ConnectivityResult.ethernet)) return ConnectivityResult.wifi; // treat ethernet as wifi
    return results.first;
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _controller =
      StreamController.broadcast();

  Stream<ConnectivityResult> get stream => _controller.stream;

  Future<ConnectivityResult> get currentStatus async {
    final result = await _connectivity.checkConnectivity();
    return _getDominantResult(result);
  }

  void dispose() {
    _controller.close();
  }
}
