// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params:
          LoginRequestParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'params': instance.params.toJson(),
    };

LoginRequestParams _$LoginRequestParamsFromJson(Map<String, dynamic> json) =>
    LoginRequestParams(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestParamsToJson(LoginRequestParams instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] == null
          ? null
          : LoginResultModel.fromJson(json['result'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : LoginErrorModel.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result?.toJson(),
      'error': instance.error?.toJson(),
    };

LoginResultModel _$LoginResultModelFromJson(Map<String, dynamic> json) =>
    LoginResultModel(
      status: json['status'] as String?,
      sessionId: json['session_id'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : UserDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResultModelToJson(LoginResultModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'session_id': instance.sessionId,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

UserDataModel _$UserDataModelFromJson(Map<String, dynamic> json) =>
    UserDataModel(
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      employeeId: (json['employee_id'] as num?)?.toInt(),
      employeeName: json['employee_name'] as String?,
      jobPosition: json['job_position'] as String?,
    );

Map<String, dynamic> _$UserDataModelToJson(UserDataModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'employee_id': instance.employeeId,
      'employee_name': instance.employeeName,
      'job_position': instance.jobPosition,
    };

LoginErrorModel _$LoginErrorModelFromJson(Map<String, dynamic> json) =>
    LoginErrorModel(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$LoginErrorModelToJson(LoginErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
