import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:threshold/core/utils/app_logger.dart';

class NetworkMonitor {
  NetworkMonitor() {
    _initInitialState();
    _connectivity.onConnectivityChanged.listen((event) {
      final next = event.isNotEmpty ? event.first : ConnectivityResult.none;
      _controller.add(next);
      logger.i('Connectivity changed: $next');
    });
  }

  Future<void> _initInitialState() async {
    final result = await _connectivity.checkConnectivity();
    final next = result.isNotEmpty ? result.first : ConnectivityResult.none;
    _controller.add(next);
    logger.i('Initial connectivity: $next');
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _controller =
      StreamController.broadcast();

  Stream<ConnectivityResult> get stream => _controller.stream;

  Future<ConnectivityResult> get currentStatus async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty ? result.first : ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
