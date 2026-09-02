part of 'home_screen_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeInitialEvent extends HomeEvent {}

final class BackPressActionEvent extends HomeEvent {}

final class LoadingEvent extends HomeEvent {}

final class HomeFetchSuccessState extends HomeEvent {}

final class LoadingErrorEvent extends HomeEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

// final class FetchConversationEvent extends HomeEvent {}

final class FetchConversationEvent extends HomeEvent {
  final bool isRefresh;
  final bool isSilent; // <-- ADD

  FetchConversationEvent({
    this.isRefresh = false,
    this.isSilent = false,
  });
}
/// Real-time chat list pushed from the socket (`contact-list-update` response).
final class UpdateChatListFromSocketEvent extends HomeEvent {
  final Map<String, dynamic> payload;

  UpdateChatListFromSocketEvent({required this.payload});
}

final class SearchConversationEvent extends HomeEvent {
  final String query;

  SearchConversationEvent(this.query);
}

class FilterConversationEvent extends HomeEvent {
  final String filterType;  
  final String filterValue; 

  FilterConversationEvent({required this.filterType, required this.filterValue});
}

final class OpenChatEvent extends HomeEvent {
  final ContactData item;

 OpenChatEvent({required this.item});
}

final class ForceLogoutEvent extends HomeEvent {}
final class FetchAgentProfileEvent extends HomeEvent {}

final class FetchCompanyProfileEvent extends HomeEvent {}

class ChangeOnlineStatusEvent extends HomeEvent {
  final String status;
  final String? publicAgentId;
  ChangeOnlineStatusEvent({required this.status, required this.publicAgentId});
}
