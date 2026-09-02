class BaseResponseModel {
  final bool success;
  final String message;
  int? code;

  BaseResponseModel({
    required this.success,
    required this.message,
    required this.code,
  });

  BaseResponseModel.fromMap(Map<String, dynamic> json)
      : success = (json['status'] == 0),
        message = json['message']?.toString() ?? '',
        code = json['code'] as int? ?? 200;
}


