import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  @JsonKey(defaultValue: '2.0')
  final String jsonrpc;
  final LoginRequestParams params;

  LoginRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class LoginRequestParams {
  final String username;
  final String password;

  LoginRequestParams({
    required this.username,
    required this.password,
  });

  factory LoginRequestParams.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestParamsToJson(this);
}

@JsonSerializable()
class LoginResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final LoginResultModel? result;
  final LoginErrorModel? error;

  LoginResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' ||
          (result?.sessionId?.isNotEmpty ?? false));

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class LoginResultModel {
  final String? status;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  final String? message;
  final UserDataModel? data;

  LoginResultModel({
    this.status,
    this.sessionId,
    this.message,
    this.data,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultModelToJson(this);
}

@JsonSerializable()
class UserDataModel {
  @JsonKey(name: 'user_id')
  final int? userId;
  final String? name;
  final String? email;
  @JsonKey(name: 'employee_id')
  final int? employeeId;
  @JsonKey(name: 'employee_name')
  final String? employeeName;
  @JsonKey(name: 'job_position')
  final String? jobPosition;

  UserDataModel({
    this.userId,
    this.name,
    this.email,
    this.employeeId,
    this.employeeName,
    this.jobPosition,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) =>
      _$UserDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataModelToJson(this);
}

@JsonSerializable()
class LoginErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  LoginErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory LoginErrorModel.fromJson(Map<String, dynamic> json) =>
      _$LoginErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginErrorModelToJson(this);
}
