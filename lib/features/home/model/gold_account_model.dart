class GoldAccountRequestModel {
  final String jsonrpc;
  final Map<String, dynamic> params;

  GoldAccountRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  factory GoldAccountRequestModel.fromJson(Map<String, dynamic> json) {
    return GoldAccountRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: (json['params'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params,
      };
}

class GoldAccountResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final GoldAccountResultModel? result;
  final GoldAccountErrorModel? error;

  GoldAccountResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory GoldAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return GoldAccountResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? GoldAccountResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? GoldAccountResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? GoldAccountErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? GoldAccountErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'id': id,
        'result': result?.toJson(),
        'error': error?.toJson(),
      };
}

class GoldAccountResultModel {
  final String? status;
  final GoldAccountDataModel? data;

  GoldAccountResultModel({
    this.status,
    this.data,
  });

  factory GoldAccountResultModel.fromJson(Map<String, dynamic> json) {
    return GoldAccountResultModel(
      status: json['status'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? GoldAccountDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? GoldAccountDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}

class GoldAccountDataModel {
  final num? totalGrams;
  final num? currentValue;
  final String? memberCode;
  final String? purity;
  final String? currencySymbol;

  GoldAccountDataModel({
    this.totalGrams,
    this.currentValue,
    this.memberCode,
    this.purity,
    this.currencySymbol,
  });

  factory GoldAccountDataModel.fromJson(Map<String, dynamic> json) {
    return GoldAccountDataModel(
      totalGrams: json['total_grams'] is num
          ? json['total_grams'] as num
          : num.tryParse(json['total_grams']?.toString() ?? ''),
      currentValue: json['current_value'] is num
          ? json['current_value'] as num
          : num.tryParse(json['current_value']?.toString() ?? ''),
      memberCode: json['member_code'] as String?,
      purity: json['purity'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_grams': totalGrams,
        'current_value': currentValue,
        'member_code': memberCode,
        'purity': purity,
        'currency_symbol': currencySymbol,
      };
}

class GoldAccountErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  GoldAccountErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory GoldAccountErrorModel.fromJson(Map<String, dynamic> json) {
    return GoldAccountErrorModel(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse(json['code']?.toString() ?? ''),
      message: json['message'] as String?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data,
      };
}
