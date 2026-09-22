import 'package:json_annotation/json_annotation.dart';

part 'register_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  @JsonKey(defaultValue: '2.0')
  final String jsonrpc;
  final RegisterRequestParams params;

  RegisterRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class RegisterRequestParams {
  final String name;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String phone;
  final String email;
  final String password;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  final String city;

  RegisterRequestParams({
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.city,
  });

  factory RegisterRequestParams.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestParamsToJson(this);
}

@JsonSerializable()
class RegisterResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final RegisterResultModel? result;
  final RegisterErrorModel? error;

  RegisterResponseModel({
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

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseModelToJson(this);
}

@JsonSerializable()
class RegisterResultModel {
  final String? status;
  final String? message;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  final RegisterUserDataModel? data;

  RegisterResultModel({
    this.status,
    this.message,
    this.sessionId,
    this.data,
  });

  factory RegisterResultModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResultModelToJson(this);
}

@JsonSerializable()
class RegisterUserDataModel {
  @JsonKey(name: 'user_id')
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  @JsonKey(name: 'partner_id')
  final int? partnerId;
  final String? city;

  RegisterUserDataModel({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.partnerId,
    this.city,
  });

  factory RegisterUserDataModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserDataModelToJson(this);
}

@JsonSerializable()
class RegisterErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  RegisterErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory RegisterErrorModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterErrorModelToJson(this);
}
