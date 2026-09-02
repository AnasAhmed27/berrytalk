import 'dart:async';
import 'dart:developer' as developer;

import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Enum/extensions.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/network/socket_service/active_chat_tracker.dart';
import 'package:berrytalks/screens/Home_screen/netwrok_calls/conversation_api_call.dart';
import 'package:berrytalks/screens/Home_screen/netwrok_calls/socket_chat_list_parser.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../Cust_Profile/newtork call/customer_profile_api_call.dart';
import '../../Settings/network_calls/settings_api_call.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  DateTime? _lastPressedAt;
  bool _isProcessingBack = false;
  List<ContactData> _allConversations = [];
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isFetchingMore = false;
  final ChatContactApiCall _chatContactApiCall = ChatContactApiCall();
  final CompanyProfileApiCall _companyProfileApiCall = CompanyProfileApiCall();
  String _currentSearchQuery = "";
  String? _selectedChannelFilter;
  String? _selectedStatusFilter;
  String _currentHintText = "Search conversations...";
  // StreamSubscription<AuthEvent>? _authSubscription;

  HomeBloc() : super(HomeInitialState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<HomeFetchSuccessState>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<FetchConversationEvent>(_onFetchConversationEvent);
    on<UpdateChatListFromSocketEvent>(_onUpdateChatListFromSocketEvent);
    on<SearchConversationEvent>(_onSearchConversationEvent);
    on<OpenChatEvent>(_onOpenChatEvent);
    on<FilterConversationEvent>(_onFilterConversationEvent);
    on<ForceLogoutEvent>(_onForceLogoutEvent);
    on<ChangeOnlineStatusEvent>(_onChangeOnlineStatusEvent);
    on<FetchAgentProfileEvent>(_onFetchAgentProfileEvent);
    on<FetchCompanyProfileEvent>(_onFetchCompanyProfileEvent);

    //     _authSubscription = AuthEventBus().stream.listen((event) async {
    //   if (event == AuthEvent.forceLogout) {
    //     await SharedPrefData.clearSession();
    //     add(ForceLogoutEvent());
    //   }
    // });
  }

  // @override
  // Future<void> close() {
  //   _authSubscription?.cancel();
  //   return super.close();
  // }

  FutureOr<void> _onForceLogoutEvent(
    ForceLogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    print("[HomeBloc] Force logout triggered");
    // await SharedPrefData.clearSession();
    // await SharedPrefData.saveIsUserLogin(false);
    emit(ForceLogoutActionState());
  }

  FutureOr<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) {
    if (_allConversations.isNotEmpty) {
      emit(
        ConversationLoadedState(
          conversations: _allConversations,
          searchHint: _currentHintText,
        ),
      );
      add(FetchConversationEvent());
    } else {
      emit(HomeInitialState());
      add(FetchConversationEvent());
    }
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (_isProcessingBack) return;
    final now = DateTime.now();
    if (_lastPressedAt != null &&
        now.difference(_lastPressedAt!) < const Duration(seconds: 2)) {
      emit(ExitAppActionState());
    } else {
      _isProcessingBack = true;
      _lastPressedAt = now;
      emit(ShowExitWarningActionState());

      await Future.delayed(const Duration(milliseconds: 300));
      _isProcessingBack = false;
    }
  }

  FutureOr<void> _onLoadingEvent(LoadingEvent event, Emitter<HomeState> emit) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    HomeFetchSuccessState event,
    Emitter<HomeState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }

  FutureOr<void> _onFetchConversationEvent(
    FetchConversationEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _isFetchingMore = false;

      if (_allConversations.isEmpty && !event.isSilent) {
      emit(LoadingState());
    }
    }

    if (_isFetchingMore) {
      return;
    }

    if (!_hasMoreData) {
      return;
    }

    _isFetchingMore = true;

    if (_currentPage > 0) {
      _applyCombinedFilters(emit);
    }

    try {
      final response = await _chatContactApiCall.fetchContactList(
        page: _currentPage,
      );

      if (response != null && response.data != null) {
        final List<ContactData> newConversations = response.data!;

        if (newConversations.isEmpty) {
          _hasMoreData = false;
        } else {
          if (_currentPage == 0) {
            _allConversations = newConversations;
          } else {
            _allConversations.addAll(newConversations);
          }

          _currentPage++;

          if (newConversations.length < 20) {
            _hasMoreData = false;
          }
        }

        emit(LoadingSuccessState());
        _applyCombinedFilters(emit);
      } else {
        if (_allConversations.isNotEmpty) {
          _applyCombinedFilters(emit);
          return;
        }

        String errorMsg =
            response?.message ?? "Something went wrong (Data was null)";
        emit(LoadingErrorState(errorTitle: "Fetch Failed", errorMsg: errorMsg));
      }
    } catch (e, stacktrace) {
      developer.log(
        "[BLOC CRASH ERROR]: ${e.toString()}",
        error: e,
        stackTrace: stacktrace,
        name: "HomeBloc",
      );
      emit(LoadingErrorState(errorTitle: "Error", errorMsg: e.toString()));
    } finally {
      _isFetchingMore = false;
      _applyCombinedFilters(emit);
    }
  }

  void _onUpdateChatListFromSocketEvent(
    UpdateChatListFromSocketEvent event,
    Emitter<HomeState> emit,
  ) {
    try {
      final conversations = SocketChatListParser.parse(event.payload);
      if (conversations == null) {
        if (kDebugMode) {
          print(
            '[HomeBloc] Socket contact-list-update: unparseable or failed payload',
          );
        }
      } else {
        _allConversations = conversations;
        _applyCombinedFilters(emit);

        if (kDebugMode) {
          print(
            '[HomeBloc] Socket contact-list-update: ${conversations.length} conversations',
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[HomeBloc] Socket contact-list-update parse error: $e');
        print(stackTrace);
      }
    }
  }

  FutureOr<void> _onSearchConversationEvent(
    SearchConversationEvent event,
    Emitter<HomeState> emit,
  ) {
    _currentSearchQuery = event.query.toLowerCase().trim();
    _applyCombinedFilters(emit);
  }

  FutureOr<void> _onFilterConversationEvent(
    FilterConversationEvent event,
    Emitter<HomeState> emit,
  ) {
    if (event.filterType == "channel") {
      _selectedChannelFilter = (_selectedChannelFilter == event.filterValue)
          ? null
          : event.filterValue;
      _currentHintText = _selectedChannelFilter != null
          ? "Search by $_selectedChannelFilter..."
          : "Search conversations...";
    } else if (event.filterType == "status") {
      _selectedStatusFilter = (_selectedStatusFilter == event.filterValue)
          ? null
          : event.filterValue;
      _currentHintText = _selectedStatusFilter != null
          ? "Search by $_selectedStatusFilter..."
          : "Search conversations...";
    } else if (event.filterType == "clear") {
      _selectedChannelFilter = null;
      _selectedStatusFilter = null;
      _currentSearchQuery = "";
      _currentHintText = "Search conversations...";
    }

    _applyCombinedFilters(emit);
  }

  void _applyCombinedFilters(Emitter<HomeState> emit) {
    List<ContactData> filteredList = _allConversations;

    if (_currentSearchQuery.isNotEmpty) {
      filteredList = filteredList.where((conversation) {
        final name = conversation.displayName.toLowerCase();
        final lastMsg = (conversation.lastMessage ?? '').toLowerCase();
        final number = (conversation.number ?? '').toLowerCase();
        return name.contains(_currentSearchQuery) ||
            lastMsg.contains(_currentSearchQuery) ||
            number.contains(_currentSearchQuery);
      }).toList();
    }

    if (_selectedChannelFilter != null) {
      final selectedChannel = _selectedChannelFilter!.toLowerCase().trim();
      filteredList = filteredList.where((conversation) {
        final channel = (conversation.chanelId ?? '').toLowerCase().trim();
        if (selectedChannel.contains("web") ||
            selectedChannel.contains("chat")) {
          return channel.contains("wechat") || channel.contains("web");
        }
        return channel.contains(selectedChannel);
      }).toList();
    }

    if (_selectedStatusFilter != null) {
      final selectedStatus = _selectedStatusFilter!.toLowerCase().trim();
      filteredList = filteredList.where((conversation) {
        switch (selectedStatus) {
          case "open":
            final unread = conversation.unReadCount;
            return unread == 0 || unread == null;

          case "waiting":
            final status = (conversation.status ?? '').toUpperCase().trim();
            return status == "PENDING";

          case "solved":
            return conversation.isChatResolved;

          case "closed":
            final status = (conversation.status ?? '').toUpperCase().trim();
            return status == "CLOSED";

          case "unread":
            final unread = conversation.unReadCount ?? 0;
            return unread > 0;

          default:
            return true;
        }
      }).toList();
    }

    bool hasActiveFilters =
        _currentSearchQuery.isNotEmpty ||
        _selectedChannelFilter != null ||
        _selectedStatusFilter != null;

    emit(
      ConversationLoadedState(
        conversations: filteredList,
        searchHint: _currentHintText,
        isFilterActive: hasActiveFilters,
        textQuery: _currentSearchQuery,
        hasMore: _hasMoreData,
        isFetchingMore: _isFetchingMore,
      ),
    );
  }

  /// Finds a loaded conversation by customer number (digits-only match).
  /// Used to open the right chat when a notification is tapped.
  ContactData? findContactByNumber(String number) {
    final target = ActiveChatTracker.normalize(number);
    if (target == null || target.isEmpty) return null;
    for (final c in _allConversations) {
      if (ActiveChatTracker.normalize(c.number) == target) return c;
    }
    return null;
  }

  FutureOr<void> _onOpenChatEvent(
    OpenChatEvent event,
    Emitter<HomeState> emit,
  ) {
    print("CHAT CARD CLICKED");
    print("CHAT USER id: ${event.item.id}");
    print("CHAT USER NAME: ${event.item.displayName}");

    emit(OpenChatActionState(item: event.item));
  }

  FutureOr<void> _onChangeOnlineStatusEvent(
    ChangeOnlineStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(LoadingState());
      final AgentProfileApiCall _profileApiCall = AgentProfileApiCall();

      final response = await _profileApiCall.updateAgentStatus(
        event.status ?? '',
        event.publicAgentId ?? '',
      );

      emit(LoadingSuccessState());

      print("[BLOC] Server updated successfully: ${response?.success}");
      if (response != null) {
        if (response.data != null) {
          print("[BLOC] Server updated successfully: ${event.status}");
          emit(
            ChangeOnlineStatusActionState(
              status: response.data?["status"] ?? '',
            ),
          );
        } else {
          final errorMsg = response?.message ?? "Failed to update status";

          emit(
            LoadingErrorState(
              errorTitle: "Status Update Failed",
              errorMsg: errorMsg,
            ),
          );
        }
      } else {
        final errorMsg = response!.message ?? "Failed to update status";

        emit(
          LoadingErrorState(
            errorTitle: "Status Update Failed",
            errorMsg: response!.message,
          ),
        );
      }
    } catch (e, stackTrac) {
      print("Exception: ${e}, StackTrac: ${stackTrac}");
      emit(
        LoadingErrorState(
          errorTitle: "Error",
          errorMsg: "Something went wrong while updating status.",
        ),
      );
    }
  }

  Future<void> _onFetchAgentProfileEvent(
    FetchAgentProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final AgentProfileApiCall _profileApiCall = AgentProfileApiCall();
      final response = await _profileApiCall.fetchAgentProfile();
      if (response != null && response.success && response.data != null) {
        emit(GetAgentProfileActionState(data: response.data!));
      } else {
        emit(
          LoadingErrorState(
            errorTitle: "Error",
            errorMsg: "Something went wrong while updating status.",
          ),
        );
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      emit(
        LoadingErrorState(
          errorTitle: "Error",
          errorMsg: "Something went wrong while updating status.",
        ),
      );
    }
  }

  Future<void> _onFetchCompanyProfileEvent(
    FetchCompanyProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final response = await _companyProfileApiCall.fetchCompanyProfile();
      if (response?.data != null) {
        emit(GetCompanyProfileDataActionState(data: response!.data!));
        if (kDebugMode) {
          print(
            '[HomeBloc] Company profile saved: ${response.data!.companyName}',
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[HomeBloc] Fetch company profile failed: $e');
        print(stackTrace);
      }
    }
  }
}
