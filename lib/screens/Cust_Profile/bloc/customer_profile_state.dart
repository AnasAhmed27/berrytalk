part of 'customer_profile_bloc.dart';

@immutable
sealed class CustomerProfileState {}

sealed class CustomerProfileActionState extends CustomerProfileState {}

final class CustomerProfileInitialState extends CustomerProfileState {}

final class BackPressActionState extends CustomerProfileActionState {}

final class LoadingState extends CustomerProfileActionState {}

final class LoadingSuccessState extends CustomerProfileActionState {}

final class LoadingErrorState extends CustomerProfileActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}

final class CustomerProfileDataState extends CustomerProfileState {
  final int activeTabIndex;
  final bool isLoading;
  final ChatContactData? contactData; 
  final String? errorMessage;
  final CompanyProfileData? companyData;

  CustomerProfileDataState({
    required this.activeTabIndex,
    required this.isLoading,
    this.contactData,
    this.errorMessage,
    this.companyData,

  });

  CustomerProfileDataState copyWith({
    int? activeTabIndex,
    bool? isLoading,
    ChatContactData? contactData,
    String? errorMessage,
    CompanyProfileData? companyData,
  }) {
    return CustomerProfileDataState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isLoading: isLoading ?? this.isLoading,
      contactData: contactData ?? this.contactData,
      errorMessage: errorMessage ?? this.errorMessage,
      companyData: companyData ?? this.companyData,
    );
  }
}