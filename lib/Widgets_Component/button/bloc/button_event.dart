part of 'button_bloc.dart';

@immutable
sealed class ButtonEvent {}

final class ButtonInitialEvent extends ButtonEvent {
  final isBtnEnabled;
  ButtonInitialEvent({this.isBtnEnabled = true});
}

class ButtonChangedEvent extends ButtonEvent {
  final bool isBtnEnabled;
  ButtonChangedEvent({required this.isBtnEnabled});
}


