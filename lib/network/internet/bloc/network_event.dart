part of 'network_bloc.dart';

abstract class NetworkEvent {}

class MonitorNetworkEvent extends NetworkEvent {}

class NetworkChangedEvent extends NetworkEvent {
  final NetworkStatus status;
  NetworkChangedEvent(this.status);
}