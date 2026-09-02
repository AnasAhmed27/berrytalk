part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable(createToJson: false)
class LoginModel extends BaseResponseModel {
  final LoginModelData? data;

  LoginModel({
    required super.success,
    required super.message,
    required super.code,
    required this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);

    return LoginModel(
      success: base.success,
      message: base.message,
      code: base.code,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? LoginModelData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'code': code,
        'data': data?.toJson(),
      };
}

@JsonSerializable()
class LoginModelData {
  final String? token;
  final String? type;
  final String? accessToken;
  final dynamic userDataResponses;

  LoginModelData({
    this.token,
    this.type,
    this.accessToken,
    this.userDataResponses,
  });

  factory LoginModelData.fromJson(Map<String, dynamic> json) =>
      _$LoginModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelDataToJson(this);
}