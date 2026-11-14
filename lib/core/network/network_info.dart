import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection internetConnection;
  final Connectivity connectivity;

  NetworkInfoImpl({
    required this.internetConnection,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    // Without a network interface there is no point probing remote hosts: the
    // HTTP HEAD checks only time out, which delays every offline read/write.
    final interfaces = await connectivity.checkConnectivity();
    if (interfaces.every((result) => result == ConnectivityResult.none)) {
      return false;
    }
    return internetConnection.hasInternetAccess;
  }
}
