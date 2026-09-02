import 'dart:async';

import 'package:berrytalks/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Team_list_screen/network_calls/team_list_api.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamListApiCall _teamChatContactApiCall = TeamListApiCall();
  String _currentSearchQuery = "";

  List<TeamContactData> _activeChats = [];
  List<TeamContactData> _directoryAgents = [];

  TeamBloc() : super(TeamInitialState()) {
    on<TeamInitialEvent>(_onTeamInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoadingSuccessEvent>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<FetchTeamConversationEvent>(_onFetchTeamConversationEvent);
    on<SearchTeamConversationEvent>(_onSearchTeamConversationEvent);
    on<OpenTeamChatEvent>(_onOpenTeamChatEvent);
    on<SelectAgentFromSheetEvent>(_onSelectAgentFromSheetEvent);
  }

  FutureOr<void> _onOpenTeamChatEvent(
    OpenTeamChatEvent event,
    Emitter<TeamState> emit,
  ) {
    emit(
      OpenTeamChatActionState(
        name: event.name,
        desStatus: event.desStatus,
        id: event.id,
      ),
    );
  }

  FutureOr<void> _onSelectAgentFromSheetEvent(
    SelectAgentFromSheetEvent event,
    Emitter<TeamState> emit,
  ) {
    final index = _activeChats.indexWhere(
      (element) =>
          element.agentId == event.selectedAgent.publicId ||
          element.conversationId == event.selectedAgent.conversationId,
    );

    if (index != -1) {
      final existingChat = _activeChats.removeAt(index);
      _activeChats.insert(0, existingChat);
    } else {
      _activeChats.insert(0, event.selectedAgent);
    }

    _applySearchFilter(emit);

    final String actualId =
        (event.selectedAgent.recipientAgentId != null &&
            event.selectedAgent.recipientAgentId!.isNotEmpty)
        ? event.selectedAgent.recipientAgentId!
        : (event.selectedAgent.publicId ?? event.selectedAgent.agentId ?? "");

    emit(
      OpenTeamChatActionState(
        name: event.selectedAgent.displayName,
        desStatus: DesigantionStatus.agent,
        id: actualId,
      ),
    );
  }

  FutureOr<void> _onTeamInitialEvent(
    TeamInitialEvent event,
    Emitter<TeamState> emit,
  ) {
    if (_activeChats.isNotEmpty) {
      emit(
        ConversationLoadedState(
          conversations: _activeChats,
          directoryAgents: _directoryAgents,
          textQuery: _currentSearchQuery,
        ),
      );
      add(FetchTeamConversationEvent());
    } else {
      emit(TeamInitialState());
      add(FetchTeamConversationEvent());
    }
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<TeamState> emit,
  ) {
    emit(BackPressActionState());
  }

  FutureOr<void> _onLoadingEvent(LoadingEvent event, Emitter<TeamState> emit) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoadingSuccessEvent event,
    Emitter<TeamState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<TeamState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }


FutureOr<void> _onFetchTeamConversationEvent(
  FetchTeamConversationEvent event,
  Emitter<TeamState> emit,
) async {
  if (_activeChats.isEmpty) {
    emit(LoadingState());
  }

  try {
    final results = await Future.wait([
      _teamChatContactApiCall.fetchInternalChatDetails(page: 0),
      _teamChatContactApiCall.fetchTeamContactList(page: 0),
    ]);

    final chatResponse = results[0] as TeamContactApiModel?;
    final directoryResponse = results[1] as TeamContactApiModel?;

    if (directoryResponse != null && directoryResponse.data != null) {
      _directoryAgents = directoryResponse.data!;
    }

    if (chatResponse != null && chatResponse.success == true && chatResponse.data != null) {
      _activeChats = chatResponse.data!;
      
      emit(LoadingSuccessState());
      _applySearchFilter(emit);
    } else {
      if (_activeChats.isNotEmpty) {
        emit(LoadingSuccessState());
        _applySearchFilter(emit);
        return;
      }

      emit(LoadingSuccessState());
      emit(
        LoadingErrorState(
          errorTitle: "Fetch Failed",
          errorMsg: chatResponse?.message ?? "Something went wrong while fetching data.",
        ),
      );
    }
  } catch (e) {
    if (_activeChats.isNotEmpty) {
      emit(LoadingSuccessState());
      _applySearchFilter(emit);
      return;
    }
    emit(LoadingSuccessState());
    emit(LoadingErrorState(errorTitle: "Error", errorMsg: e.toString()));
  }
}

  FutureOr<void> _onSearchTeamConversationEvent(
    SearchTeamConversationEvent event,
    Emitter<TeamState> emit,
  ) {
    _currentSearchQuery = event.query.toLowerCase().trim();
    _applySearchFilter(emit);
  }



void _applySearchFilter(Emitter<TeamState> emit) {
  List<TeamContactData> filteredList = List.from(_activeChats);

  final Map<String, String> statusByEmail = {};
  final Map<String, String> statusById = {};
  
  final Map<String, String> statusByName = {}; 
  final Map<String, String> phoneByName = {};

  for (var agent in _directoryAgents) {
    final status = agent.status ?? "OFFLINE";
    
    if (agent.email != null && agent.email!.isNotEmpty) {
      statusByEmail[agent.email!.toLowerCase().trim()] = status;
    }
    
    if (agent.publicId != null) statusById[agent.publicId!] = status;
    if (agent.agentId != null) statusById[agent.agentId!] = status;

    final cleanName = agent.displayName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanName.isNotEmpty && cleanName != "unknown agent / user") {
      statusByName[cleanName] = status;
      if (agent.phoneNumberWork != null) {
        phoneByName[cleanName] = agent.phoneNumberWork!;
      }
    }
  }

  filteredList = filteredList.map((conversation) {
    String matchedStatus = "OFFLINE"; 
    bool isMatched = false;

    if (conversation.email != null && 
        conversation.email!.isNotEmpty && 
        statusByEmail.containsKey(conversation.email!.toLowerCase().trim())) {
      matchedStatus = statusByEmail[conversation.email!.toLowerCase().trim()]!;
      isMatched = true;
    } 
    else if (conversation.recipientAgentId != null && statusById.containsKey(conversation.recipientAgentId)) {
      matchedStatus = statusById[conversation.recipientAgentId]!;
      isMatched = true;
    } 
    else if (conversation.agentId != null && statusById.containsKey(conversation.agentId)) {
      matchedStatus = statusById[conversation.agentId]!;
      isMatched = true;
    } 
    else if (conversation.publicId != null && statusById.containsKey(conversation.publicId)) {
      matchedStatus = statusById[conversation.publicId]!;
      isMatched = true;
    } 

    if (!isMatched) {
      final cleanConvName = conversation.displayName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (cleanConvName.isNotEmpty && statusByName.containsKey(cleanConvName)) {
        if (conversation.phoneNumberWork != null && 
            phoneByName.containsKey(cleanConvName) && 
            phoneByName[cleanConvName] == conversation.phoneNumberWork) {
          matchedStatus = statusByName[cleanConvName]!;
        } else {
          matchedStatus = statusByName[cleanConvName]!;
        }
      } else {
        matchedStatus = conversation.status ?? "OFFLINE";
      }
    }

    return TeamContactData(
      publicId: conversation.publicId,
      companyPublicId: conversation.companyPublicId,
      status: matchedStatus, 
      email: conversation.email,
      firstName: conversation.firstName,
      lastName: conversation.lastName,
      role: conversation.role,
      profilePic: conversation.profilePic,
      phoneNumberWork: conversation.phoneNumberWork,
      senderAgentId: conversation.senderAgentId,
      recipientAgentId: conversation.recipientAgentId,
      agentId: conversation.agentId,
      customerName: conversation.customerName,
      lastMessage: conversation.lastMessage,
      timestamp: conversation.timestamp,
      recipientUnReadCount: conversation.recipientUnReadCount,
      senderUnReadCount: conversation.senderUnReadCount,
      conversationId: conversation.conversationId,
    );
  }).toList();

  if (_currentSearchQuery.isNotEmpty) {
    filteredList = filteredList.where((conversation) {
      final name = conversation.displayName.toLowerCase();
      final lastMsg = (conversation.lastMessage ?? '').toLowerCase();
      return name.contains(_currentSearchQuery) || lastMsg.contains(_currentSearchQuery);
    }).toList();
  }

  emit(
    ConversationLoadedState(
      conversations: filteredList,
      isFilterActive: _currentSearchQuery.isNotEmpty,
      directoryAgents: _directoryAgents,
      textQuery: _currentSearchQuery,
    ),
  );
}
}
