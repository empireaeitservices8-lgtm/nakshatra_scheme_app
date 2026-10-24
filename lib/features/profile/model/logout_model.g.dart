// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogoutRequestModel _$LogoutRequestModelFromJson(Map<String, dynamic> json) =>
    LogoutRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: (json['params'] as Map<String, dynamic>?) ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$LogoutRequestModelToJson(LogoutRequestModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'params': instance.params,
    };

LogoutResponseModel _$LogoutResponseModelFromJson(Map<String, dynamic> json) =>
    LogoutResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] == null
          ? null
          : LogoutResultModel.fromJson(json['result'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : LogoutErrorModel.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LogoutResponseModelToJson(
        LogoutResponseModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result?.toJson(),
      'error': instance.error?.toJson(),
    };

LogoutResultModel _$LogoutResultModelFromJson(Map<String, dynamic> json) =>
    LogoutResultModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LogoutResultModelToJson(LogoutResultModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };

LogoutErrorModel _$LogoutErrorModelFromJson(Map<String, dynamic> json) =>
    LogoutErrorModel(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$LogoutErrorModelToJson(LogoutErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
