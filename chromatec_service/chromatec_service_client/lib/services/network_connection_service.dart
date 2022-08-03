import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectionService {
  static NetworkConnectionService instance = NetworkConnectionService();

  Future<bool> get isOffline async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.none;
  }  
}