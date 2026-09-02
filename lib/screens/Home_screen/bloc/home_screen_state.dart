part of 'home_screen_bloc.dart';

@immutable
sealed class HomeState {}

sealed class HomeActionState extends HomeState {}

final class HomeInitialState extends HomeState {}

final class BackPressActionState extends HomeActionState {}

final class LoadingState extends HomeActionState {}

final class LoadingSuccessState extends HomeActionState {}

final class LoadingErrorState extends HomeActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}

class ConversationNoLoadedState extends HomeActionState {}


class ConversationLoadedState extends HomeState {
  final List<ContactData> conversations; 
  final String searchHint;
  final bool isFilterActive;
  final String textQuery; 
  final bool hasMore;
  final bool isFetchingMore;

  ConversationLoadedState({
    required this.conversations,
    this.searchHint = "Search conversations...",
    this.isFilterActive = false,
    this.textQuery = "", 
    this.hasMore = true,
    this.isFetchingMore = false,
  });
}

final class OpenChatActionState extends HomeActionState {
  final ContactData item; 

  OpenChatActionState({required this.item});
}

final class ShowExitWarningActionState extends HomeActionState {}

final class ExitAppActionState extends HomeActionState {}

final class ForceLogoutActionState extends HomeActionState {}
final class ChangeOnlineStatusActionState extends HomeActionState {
  final String? status;
  ChangeOnlineStatusActionState({required this.status});
}
final class GetAgentProfileActionState extends HomeActionState {
  final AgentProfileData? data;
  GetAgentProfileActionState({required this.data});
}

final class GetCompanyProfileDataActionState extends HomeActionState {
  final CompanyProfileData? data;
  GetCompanyProfileDataActionState({required this.data});
}