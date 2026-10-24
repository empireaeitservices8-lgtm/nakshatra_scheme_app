// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_gold_price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveGoldPriceRequestModel _$LiveGoldPriceRequestModelFromJson(
        Map<String, dynamic> json) =>
    LiveGoldPriceRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: (json['params'] as Map<String, dynamic>?) ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$LiveGoldPriceRequestModelToJson(
        LiveGoldPriceRequestModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'params': instance.params,
    };

LiveGoldPriceResponseModel _$LiveGoldPriceResponseModelFromJson(
        Map<String, dynamic> json) =>
    LiveGoldPriceResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] == null
          ? null
          : LiveGoldPriceResultModel.fromJson(
              json['result'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : LiveGoldPriceErrorModel.fromJson(
              json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveGoldPriceResponseModelToJson(
        LiveGoldPriceResponseModel instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result,
      'error': instance.error,
    };

LiveGoldPriceResultModel _$LiveGoldPriceResultModelFromJson(
        Map<String, dynamic> json) =>
    LiveGoldPriceResultModel(
      status: json['status'] as String?,
      data: json['data'] == null
          ? null
          : LiveGoldPriceDataModel.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveGoldPriceResultModelToJson(
        LiveGoldPriceResultModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

LiveGoldPriceDataModel _$LiveGoldPriceDataModelFromJson(
        Map<String, dynamic> json) =>
    LiveGoldPriceDataModel(
      goldPricePerGram: json['gold_price_per_gram'] as num?,
      unit: json['unit'] as String?,
      boardRate: json['board_rate'] as num?,
      purity: json['purity'] as String?,
      changePercentage: json['change_percentage'] as num?,
      currencySymbol: json['currency_symbol'] as String?,
    );

Map<String, dynamic> _$LiveGoldPriceDataModelToJson(
        LiveGoldPriceDataModel instance) =>
    <String, dynamic>{
      'gold_price_per_gram': instance.goldPricePerGram,
      'unit': instance.unit,
      'board_rate': instance.boardRate,
      'purity': instance.purity,
      'change_percentage': instance.changePercentage,
      'currency_symbol': instance.currencySymbol,
    };

LiveGoldPriceErrorModel _$LiveGoldPriceErrorModelFromJson(
        Map<String, dynamic> json) =>
    LiveGoldPriceErrorModel(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$LiveGoldPriceErrorModelToJson(
        LiveGoldPriceErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
