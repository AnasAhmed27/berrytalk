part of 'bottom_nav_bar_bloc.dart';

abstract class NavigationEvent {}
class TabChanged extends NavigationEvent {
  final int index;
  TabChanged(this.index);
}