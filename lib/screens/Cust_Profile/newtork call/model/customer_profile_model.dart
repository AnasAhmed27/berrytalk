part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable(explicitToJson: true)
class CompanyProfileApiModel {
  final num? status;
  final String? message;
  final CompanyProfileData? data;

  CompanyProfileApiModel({this.status, this.message, this.data});

  factory CompanyProfileApiModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileApiModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? CompanyProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

@JsonSerializable(explicitToJson: true)
class CompanyProfileData {
  final int? ccId;
  final String? publicId;
  final String? companyName;
  final String? businessNumber;
  final String? email;
  final String? whatsappNumber;
  final String? industry;
  final String? type;
  final String? domain;
  final bool? isVerified;
  final List<String>? activeApps; 

  CompanyProfileData({
    this.ccId,
    this.publicId,
    this.companyName,
    this.businessNumber,
    this.email,
    this.whatsappNumber,
    this.industry,
    this.type,
    this.domain,
    this.isVerified,
    this.activeApps,
  });

  factory CompanyProfileData.fromJson(Map<String, dynamic> json) {
    return CompanyProfileData(
      ccId: json['cc_id'],
      publicId: json['publicId'],
      companyName: json['companyName'],
      businessNumber: json['businessNumber'],
      email: json['email'],
      whatsappNumber: json['whatsappNumber'],
      industry: json['industry'],
      type: json['type'],
      domain: json['domain'],
      isVerified: json['isVerified'],
      activeApps: json['activeApps'] != null
          ? List<String>.from(json['activeApps'].map((x) => x.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'cc_id': ccId,
        'publicId': publicId,
        'companyName': companyName,
        'businessNumber': businessNumber,
        'email': email,
        'whatsappNumber': whatsappNumber,
        'industry': industry,
        'type': type,
        'domain': domain,
        'isVerified': isVerified,
        'activeApps': activeApps,
      };
}