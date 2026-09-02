part of 'customer_profile_bloc.dart';

@immutable
sealed class CustomerProfileEvent {}

final class CustomerProfileInitialEvent extends CustomerProfileEvent {}

final class BackPressActionEvent extends CustomerProfileEvent {}

final class LoadingEvent extends CustomerProfileEvent {}

final class LoadingSuccessEvent extends CustomerProfileEvent {}

final class LoadingErrorEvent extends CustomerProfileEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

final class LoadCustomerProfileEvent extends CustomerProfileEvent {
  final String number;
  final String companyPublicId;
  final String agentId;
  final String channelId;

  LoadCustomerProfileEvent({
    required this.number,
    required this.companyPublicId,
    required this.agentId,
    required this.channelId,
  });
}

final class ToggleTabEvent extends CustomerProfileEvent {
  final int tabIndex; 
  ToggleTabEvent(this.tabIndex);
}
