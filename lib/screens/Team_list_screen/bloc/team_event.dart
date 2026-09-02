part of 'team_bloc.dart';

@immutable
sealed class TeamEvent {}

final class TeamInitialEvent extends TeamEvent {}

final class BackPressActionEvent extends TeamEvent {}

final class LoadingEvent extends TeamEvent {}

final class LoadingSuccessEvent extends TeamEvent {}

final class LoadingErrorEvent extends TeamEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}


final class FetchTeamConversationEvent extends TeamEvent {}

final class SearchTeamConversationEvent extends TeamEvent {
  final String query;

  SearchTeamConversationEvent(this.query);
}

final class OpenTeamChatEvent extends TeamEvent {
  final String name;
   final DesigantionStatus desStatus;
   final String id;

  OpenTeamChatEvent({
    required this.name,
    required this.desStatus,
    required this.id,
  });
}