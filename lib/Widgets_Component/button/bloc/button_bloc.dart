import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'button_event.dart';
part 'button_state.dart';

class ButtonBloc extends Bloc<ButtonEvent, ButtonState> {
  ButtonBloc() : super(ButtonInitialState()) {
    on<ButtonInitialEvent>(_onButtonInitialEvent);
    on<ButtonChangedEvent>(_onButtonChangedEvent);
  }

  FutureOr<void> _onButtonInitialEvent(ButtonInitialEvent event, Emitter<ButtonState> emit) {
    emit(ButtonInitialState(isBtnEnabled: event.isBtnEnabled));
  }

  FutureOr<void> _onButtonChangedEvent(ButtonChangedEvent event, Emitter<ButtonState> emit) {
    emit(ButtonChangedState(isBtnEnabled: event.isBtnEnabled));
  }
}
