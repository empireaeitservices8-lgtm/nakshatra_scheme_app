import 'package:json_annotation/json_annotation.dart';

part 'live_gold_price_model.g.dart';

@JsonSerializable()
class LiveGoldPriceRequestModel {
  @JsonKey(defaultValue: '2.0')
  final String jsonrpc;
  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> params;

  LiveGoldPriceRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  factory LiveGoldPriceRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LiveGoldPriceRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGoldPriceRequestModelToJson(this);
}

@JsonSerializable()
class LiveGoldPriceResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final LiveGoldPriceResultModel? result;
  final LiveGoldPriceErrorModel? error;

  LiveGoldPriceResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory LiveGoldPriceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LiveGoldPriceResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGoldPriceResponseModelToJson(this);
}

@JsonSerializable()
class LiveGoldPriceResultModel {
  final String? status;
  final LiveGoldPriceDataModel? data;

  LiveGoldPriceResultModel({
    this.status,
    this.data,
  });

  factory LiveGoldPriceResultModel.fromJson(Map<String, dynamic> json) =>
      _$LiveGoldPriceResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGoldPriceResultModelToJson(this);
}

@JsonSerializable()
class LiveGoldPriceDataModel {
  @JsonKey(name: 'gold_price_per_gram')
  final num? goldPricePerGram;
  final String? unit;
  @JsonKey(name: 'board_rate')
  final num? boardRate;
  final String? purity;
  @JsonKey(name: 'change_percentage')
  final num? changePercentage;
  @JsonKey(name: 'currency_symbol')
  final String? currencySymbol;

  LiveGoldPriceDataModel({
    this.goldPricePerGram,
    this.unit,
    this.boardRate,
    this.purity,
    this.changePercentage,
    this.currencySymbol,
  });

  factory LiveGoldPriceDataModel.fromJson(Map<String, dynamic> json) =>
      _$LiveGoldPriceDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGoldPriceDataModelToJson(this);
}

@JsonSerializable()
class LiveGoldPriceErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  LiveGoldPriceErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory LiveGoldPriceErrorModel.fromJson(Map<String, dynamic> json) =>
      _$LiveGoldPriceErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGoldPriceErrorModelToJson(this);
}
