import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus { connected, weak, disconnected }


class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<NetworkStatus> get networkStatusStream async* {
    await for (final List<ConnectivityResult> results in _connectivity.onConnectivityChanged) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        yield NetworkStatus.disconnected;
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        yield await checkInternetQuality();
      }
    }
  }

  Future<NetworkStatus> checkInternetQuality() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 3), 
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        if (stopwatch.elapsedMilliseconds > 1500) {
          print("Network Warning: Weak Signals Detected! (${stopwatch.elapsedMilliseconds}ms)");
          return NetworkStatus.weak;
        }
        return NetworkStatus.connected;
      }
      return NetworkStatus.disconnected;
    } on SocketException catch (_) {
      return NetworkStatus.disconnected;
    } on TimeoutException catch (_) {
      print("Network Timeout: Signaling is very weak!");
      return NetworkStatus.weak;
    } catch (_) {
      return NetworkStatus.disconnected;
    }
  }
}

