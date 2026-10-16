class ProfileRequestModel {
  final String jsonrpc;
  final String method;
  final ProfileRequestParams params;
  final int id;

  ProfileRequestModel({
    this.jsonrpc = '2.0',
    this.method = 'call',
    required this.params,
    this.id = 1,
  });

  factory ProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return ProfileRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String? ?? 'call',
      params: json['params'] != null && json['params'] is Map<String, dynamic>
          ? ProfileRequestParams.fromJson(json['params'] as Map<String, dynamic>)
          : ProfileRequestParams(userId: 1),
      id: json['id'] is int ? json['id'] as int : 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'method': method,
        'params': params.toJson(),
        'id': id,
      };
}

class ProfileRequestParams {
  final int userId;

  ProfileRequestParams({required this.userId});

  factory ProfileRequestParams.fromJson(Map<String, dynamic> json) {
    return ProfileRequestParams(
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
      };
}

class ProfileResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final ProfileResultModel? result;
  final ProfileErrorModel? error;

  ProfileResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? ProfileResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? ProfileResultModel.fromJson(
                  Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? ProfileErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? ProfileErrorModel.fromJson(
                  Map<String, dynamic>.from(json['error'] as Map))
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

class ProfileResultModel {
  final String? status;
  final ProfileDataModel? data;

  ProfileResultModel({
    this.status,
    this.data,
  });

  factory ProfileResultModel.fromJson(Map<String, dynamic> json) {
    return ProfileResultModel(
      status: json['status'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? ProfileDataModel.fromJson(
                  Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}

class ProfileDataModel {
  final int? userId;
  final String? name;
  final String? initials;
  final String? memberCode;
  final String? memberSince;
  final String? goldBalance;
  final num? goldBalanceRaw;
  final String? totalValue;
  final num? totalValueRaw;
  final String? currencySymbol;

  ProfileDataModel({
    this.userId,
    this.name,
    this.initials,
    this.memberCode,
    this.memberSince,
    this.goldBalance,
    this.goldBalanceRaw,
    this.totalValue,
    this.totalValueRaw,
    this.currencySymbol,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      name: json['name'] as String?,
      initials: json['initials'] as String?,
      memberCode: json['member_code'] as String?,
      memberSince: json['member_since'] as String?,
      goldBalance: json['gold_balance'] as String?,
      goldBalanceRaw: json['gold_balance_raw'] is num
          ? json['gold_balance_raw'] as num
          : num.tryParse(json['gold_balance_raw']?.toString() ?? ''),
      totalValue: json['total_value'] as String?,
      totalValueRaw: json['total_value_raw'] is num
          ? json['total_value_raw'] as num
          : num.tryParse(json['total_value_raw']?.toString() ?? ''),
      currencySymbol: json['currency_symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'initials': initials,
        'member_code': memberCode,
        'member_since': memberSince,
        'gold_balance': goldBalance,
        'gold_balance_raw': goldBalanceRaw,
        'total_value': totalValue,
        'total_value_raw': totalValueRaw,
        'currency_symbol': currencySymbol,
      };
}

class ProfileErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  ProfileErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory ProfileErrorModel.fromJson(Map<String, dynamic> json) {
    return ProfileErrorModel(
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
