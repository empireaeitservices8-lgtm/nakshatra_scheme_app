// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: RegisterRequestParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'params': instance.params.toJson(),
    };

RegisterRequestParams _$RegisterRequestParamsFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestParams(
      name: json['name'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
      city: json['city'] as String,
    );

Map<String, dynamic> _$RegisterRequestParamsToJson(
        RegisterRequestParams instance) =>
    <String, dynamic>{
      'name': instance.name,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'email': instance.email,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
      'city': instance.city,
    };

RegisterResponseModel _$RegisterResponseModelFromJson(
        Map<String, dynamic> json) =>
    RegisterResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] == null
          ? null
          : RegisterResultModel.fromJson(
              json['result'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : RegisterErrorModel.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseModelToJson(
        RegisterResponseModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result?.toJson(),
      'error': instance.error?.toJson(),
    };

RegisterResultModel _$RegisterResultModelFromJson(Map<String, dynamic> json) =>
    RegisterResultModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      sessionId: json['session_id'] as String?,
      data: json['data'] == null
          ? null
          : RegisterUserDataModel.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResultModelToJson(
        RegisterResultModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'session_id': instance.sessionId,
      'data': instance.data?.toJson(),
    };

RegisterUserDataModel _$RegisterUserDataModelFromJson(
        Map<String, dynamic> json) =>
    RegisterUserDataModel(
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      partnerId: (json['partner_id'] as num?)?.toInt(),
      city: json['city'] as String?,
    );

Map<String, dynamic> _$RegisterUserDataModelToJson(
        RegisterUserDataModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'partner_id': instance.partnerId,
      'city': instance.city,
    };

RegisterErrorModel _$RegisterErrorModelFromJson(Map<String, dynamic> json) =>
    RegisterErrorModel(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$RegisterErrorModelToJson(RegisterErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
