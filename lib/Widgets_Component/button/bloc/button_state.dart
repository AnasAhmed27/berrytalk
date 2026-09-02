part of 'button_bloc.dart';

@immutable
sealed class ButtonState {}

final class ButtonInitialState extends ButtonState {
  final isBtnEnabled;
  ButtonInitialState({this.isBtnEnabled = true});
}

final class ButtonChangedState extends ButtonState {
  final isBtnEnabled;
  ButtonChangedState({required this.isBtnEnabled});
}
