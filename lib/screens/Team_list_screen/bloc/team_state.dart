part of 'team_bloc.dart';

@immutable
sealed class TeamState {}

sealed class TeamActionState extends TeamState {}

final class TeamInitialState extends TeamState {}

final class BackPressActionState extends TeamActionState {}

final class LoadingState extends TeamActionState {}

final class LoadingSuccessState extends TeamActionState {}

final class LoadingErrorState extends TeamState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}


class ConversationLoadedState extends TeamState {
  final List<TeamContactData> conversations; 
  final List<TeamContactData> directoryAgents; 
  final String searchHint;
  final bool isFilterActive;
  final String textQuery; 

  ConversationLoadedState({
    required this.conversations,
    this.directoryAgents = const [], 
    this.searchHint = "Search conversations...",
    this.isFilterActive = false,
    this.textQuery = "", 
  });
}

class SelectAgentFromSheetEvent extends TeamEvent {
  final TeamContactData selectedAgent;
  SelectAgentFromSheetEvent(this.selectedAgent);
}


final class OpenTeamChatActionState extends TeamActionState {
  final String name;
  final DesigantionStatus desStatus;
  final String id;

  OpenTeamChatActionState({
    required this.name,
    required this.desStatus,
    required this.id
  });
}