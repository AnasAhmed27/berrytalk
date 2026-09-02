import 'dart:async';
import 'dart:developer' as developer;
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Chat_screen/network_calls/chatScreen_api_call.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../newtork call/customer_profile_api_call.dart';

part 'customer_profile_event.dart';
part 'customer_profile_state.dart';

class CustomerProfileBloc
    extends Bloc<CustomerProfileEvent, CustomerProfileState> {
 final ChatDetailsApiCall _apiCall = ChatDetailsApiCall(); 
  final CompanyProfileApiCall _companyApiCall = CompanyProfileApiCall();

  CustomerProfileBloc() : super(CustomerProfileInitialState()) {
    on<CustomerProfileInitialEvent>(_onCustomerProfileInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoadingSuccessEvent>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<LoadCustomerProfileEvent>(_onLoadCustomerProfileEvent);
    on<ToggleTabEvent>(_onToggleTabEvent);
  }

  FutureOr<void> _onCustomerProfileInitialEvent(
    CustomerProfileInitialEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    emit(CustomerProfileInitialState());
  }

Future<void> _onLoadCustomerProfileEvent(
    LoadCustomerProfileEvent event,
    Emitter<CustomerProfileState> emit,
  ) async {
    emit(
      CustomerProfileDataState(
        activeTabIndex: 0,
        isLoading: true,
        contactData: null,
        companyData: null,
      ),
    );

    try {
      developer.log("=== STARTING PROFILE DATA FETCH ===", name: "CustomerProfileBloc");

      // 2. FIXED HERE: Wapas chat details ki exact API sahi parameters ke sath call ho rahi hai
      final chatResponse = await _apiCall.fetchChatDetails(
        number: event.number,
        companyPublicId: event.companyPublicId,
        agentId: event.agentId,
        channelId: event.channelId,
      );

      // 3. Fetch Company Details (Iska token function ke andar khud get ho raha hai)
      final companyResponse = await _companyApiCall.fetchCompanyProfile();

      // --- DEVELOPER LOGS FOR DEBUGGING ---
      if (chatResponse != null) {
        developer.log(
          "CUSTOMER DATA RECEIVED: Name: ${chatResponse.data?.contact?.fullName} | Address: ${chatResponse.data?.contact?.address}", 
          name: "CustomerProfileBloc"
        );
      }
      
      if (companyResponse != null && companyResponse.data != null) {
        developer.log(
          "COMPANY DATA RECEIVED: Name: ${companyResponse.data?.companyName} | Email: ${companyResponse.data?.email} | Domain/Location: ${companyResponse.data?.domain}", 
          name: "CustomerProfileBloc"
        );
      } else {
        developer.log("COMPANY DATA WAS NULL OR FAILED!", name: "CustomerProfileBloc");
      }
      // -------------------------------------

      final contact = chatResponse?.data?.contact;
      final company = companyResponse?.data;

      // Agar dono me se koi ek data bhi sahi mil jaye toh UI render ho jaye
      if (chatResponse?.success == true || companyResponse != null) {
        emit(
          CustomerProfileDataState(
            activeTabIndex: 0,
            isLoading: false,
            contactData: contact,
            companyData: company, 
          ),
        );
      } else {
        emit(
          CustomerProfileDataState(
            activeTabIndex: 0,
            isLoading: false,
            contactData: null,
            companyData: null,
            errorMessage: "Failed to fetch profile data.",
          ),
        );
      }
    } catch (e, stack) {
      developer.log("PROFILE FETCH EXCEPTION: $e", stackTrace: stack, name: "CustomerProfileBloc");
      emit(
        CustomerProfileDataState(
          activeTabIndex: 0,
          isLoading: false,
          contactData: null,
          companyData: null,
          errorMessage: "Something went wrong: ${e.toString()}",
        ),
      );
    }
  }

  // Future<void> _onLoadCustomerProfileEvent(
  //   LoadCustomerProfileEvent event,
  //   Emitter<CustomerProfileState> emit,
  // ) async {
  //   emit(
  //     CustomerProfileDataState(
  //       activeTabIndex: 0,
  //       isLoading: true,
  //       contactData: null,
  //     ),
  //   );

  //   try {
  //     final response = await _apiCall.fetchChatDetails(
  //       number: event.number,
  //       companyPublicId: event.companyPublicId,
  //       agentId: event.agentId,
  //       channelId: event.channelId,
  //     );

  //     if (response != null &&
  //         response.success == true &&
  //         response.data?.contact != null) {
  //       emit(
  //         CustomerProfileDataState(
  //           activeTabIndex: 0,
  //           isLoading: false,
  //           contactData: response.data!.contact,
  //         ),
  //       );
  //     } else {
  //       emit(
  //         CustomerProfileDataState(
  //           activeTabIndex: 0,
  //           isLoading: false,
  //           contactData: null,
  //           errorMessage:
  //               response?.message ?? "Failed to fetch customer profile data.",
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     emit(
  //       CustomerProfileDataState(
  //         activeTabIndex: 0,
  //         isLoading: false,
  //         contactData: null,
  //         errorMessage: "Something went wrong: ${e.toString()}",
  //       ),
  //     );
  //   }
  // }

  FutureOr<void> _onToggleTabEvent(
    ToggleTabEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    if (state is CustomerProfileDataState) {
      final currentState = state as CustomerProfileDataState;
      emit(currentState.copyWith(activeTabIndex: event.tabIndex));
    }
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    emit(BackPressActionState());
  }

  FutureOr<void> _onLoadingEvent(
    LoadingEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoadingSuccessEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<CustomerProfileState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }
}
