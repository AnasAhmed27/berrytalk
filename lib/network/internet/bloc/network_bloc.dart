import 'dart:async';

import 'package:berrytalks/network/internet/network/NetworkService.dart';
import 'package:bloc/bloc.dart';

part 'network_event.dart';
part 'network_state.dart';


class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription? _networkSubscription;
  Timer? _recoveryTimer; 

  NetworkBloc() : super(NetworkInitialState()) {
    on<MonitorNetworkEvent>(_onMonitorNetworkEvent);
    on<NetworkChangedEvent>(_onNetworkChangedEvent);
  }

  FutureOr<void> _onMonitorNetworkEvent(
    MonitorNetworkEvent event,
    Emitter<NetworkState> emit,
  ) {
    _networkSubscription?.cancel();
    _networkSubscription = _networkService.networkStatusStream.listen((status) {
      add(NetworkChangedEvent(status));
    });
  }

  FutureOr<void> _onNetworkChangedEvent(
    NetworkChangedEvent event,
    Emitter<NetworkState> emit,
  ) {
    _recoveryTimer?.cancel();

    if (event.status == NetworkStatus.connected) {
      if (state is NetworkDisconnectedState || state is NetworkWeakState) {
        emit(NetworkConnectedState(isRestored: true)); 
      } else {
        emit(NetworkConnectedState(isRestored: false));
      }
    } 
    else if (event.status == NetworkStatus.weak) {
      emit(NetworkWeakState());

      _recoveryTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
        final currentStatus = await _networkService.checkInternetQuality();
        if (currentStatus != NetworkStatus.weak) {
          timer.cancel();
          add(NetworkChangedEvent(currentStatus));
        }
      });
    } 
    else {
      emit(NetworkDisconnectedState());
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _recoveryTimer?.cancel();
    return super.close();
  }
}