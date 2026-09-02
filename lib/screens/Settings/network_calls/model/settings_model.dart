part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable(createToJson: false)
class AgentProfileModel extends BaseResponseModel {
  final AgentProfileData? data;

  AgentProfileModel({
    required super.success,
    required super.message,
    required super.code,
    required this.data,
  });

  factory AgentProfileModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);
    
    return AgentProfileModel(
      success: base.success,
      message: base.message,
      code: base.code,
      data: json['data'] != null 
          ? AgentProfileData.fromJson(json['data'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': success ? 1 : 0,
        'message': message,
        'code': code,
        'data': data?.toJson(),
      };
}

@JsonSerializable()
class AgentProfileData {
  final String? publicId;
  final String? companyPublicId;
  final String? phoneNumberWork;
  final String? status; 
  final String? agentType; 
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  final String? role;

  AgentProfileData({
    this.publicId,
    this.companyPublicId,
    this.phoneNumberWork,
    this.status,
    this.agentType,
    this.email,
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.role,
  });

  factory AgentProfileData.fromJson(Map<String, dynamic> json) =>
      _$AgentProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$AgentProfileDataToJson(this);

  String get fullName {
    if ((firstName == null || firstName!.isEmpty) && (lastName == null || lastName!.isEmpty)) {
      return "Unknown Agent";
    }
    return "${firstName ?? ''} ${lastName ?? ''}".trim();
  }
}

@JsonSerializable(createToJson: false)
class StatusChangeResponseModel extends BaseResponseModel {
  final dynamic data; 
  StatusChangeResponseModel({
    required super.success,
    required super.message,
    required super.code,
    this.data,
  });

  factory StatusChangeResponseModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);
    
    return StatusChangeResponseModel(
      success: base.success,
      message: base.message,
      code: base.code,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': success ? 1 : 0,
        'message': message,
        'code': code,
        'data': data,
      };
}