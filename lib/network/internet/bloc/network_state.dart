part of 'network_bloc.dart';

abstract class NetworkState {
  final NetworkStatus status;
  NetworkState(this.status);
}

class NetworkInitialState extends NetworkState {
  NetworkInitialState() : super(NetworkStatus.connected);
}

class NetworkConnectedState extends NetworkState {
  final bool isRestored;
  NetworkConnectedState({this.isRestored = false}) : super(NetworkStatus.connected);
}

class NetworkWeakState extends NetworkState {
  NetworkWeakState() : super(NetworkStatus.weak);
}

class NetworkDisconnectedState extends NetworkState {
  NetworkDisconnectedState() : super(NetworkStatus.disconnected);
}