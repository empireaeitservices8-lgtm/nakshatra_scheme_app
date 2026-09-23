class JoinSchemeRequestModel {
  final String jsonrpc;
  final JoinSchemeRequestParams params;

  JoinSchemeRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  factory JoinSchemeRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinSchemeRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: json['params'] != null
          ? JoinSchemeRequestParams.fromJson(json['params'] as Map<String, dynamic>)
          : JoinSchemeRequestParams(
              userId: 1,
              schemeType: 'fixed_weight',
              monthlyInstallment: 5000.0,
              duration: 11,
              nominee: '',
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params.toJson(),
      };
}

class JoinSchemeRequestParams {
  final int userId;
  final String schemeType;
  final double monthlyInstallment;
  final int duration;
  final String nominee;

  JoinSchemeRequestParams({
    required this.userId,
    required this.schemeType,
    required this.monthlyInstallment,
    required this.duration,
    required this.nominee,
  });

  factory JoinSchemeRequestParams.fromJson(Map<String, dynamic> json) {
    return JoinSchemeRequestParams(
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      schemeType: json['scheme_type'] as String? ?? 'fixed_weight',
      monthlyInstallment: json['monthly_installment'] is num
          ? (json['monthly_installment'] as num).toDouble()
          : double.tryParse(json['monthly_installment']?.toString() ?? '5000') ?? 5000.0,
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '11') ?? 11,
      nominee: json['nominee'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'scheme_type': schemeType,
        'monthly_installment': monthlyInstallment,
        'duration': duration,
        'nominee': nominee,
      };
}

class JoinSchemeResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final JoinSchemeResultModel? result;
  final JoinSchemeErrorModel? error;

  JoinSchemeResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' || result?.data != null);

  factory JoinSchemeResponseModel.fromJson(Map<String, dynamic> json) {
    return JoinSchemeResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? JoinSchemeResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? JoinSchemeResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? JoinSchemeErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? JoinSchemeErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class JoinSchemeResultModel {
  final String? status;
  final String? message;
  final JoinSchemeDataModel? data;

  JoinSchemeResultModel({
    this.status,
    this.message,
    this.data,
  });

  factory JoinSchemeResultModel.fromJson(Map<String, dynamic> json) {
    return JoinSchemeResultModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? JoinSchemeDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? JoinSchemeDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class JoinSchemeDataModel {
  final int? enrollmentId;
  final String? schemeType;
  final num? monthlyInstallment;
  final dynamic duration;
  final String? nominee;
  final String? estimatedGoldPerMonth;
  final num? firstInstallmentAmount;
  final String? currencySymbol;

  JoinSchemeDataModel({
    this.enrollmentId,
    this.schemeType,
    this.monthlyInstallment,
    this.duration,
    this.nominee,
    this.estimatedGoldPerMonth,
    this.firstInstallmentAmount,
    this.currencySymbol,
  });

  factory JoinSchemeDataModel.fromJson(Map<String, dynamic> json) {
    return JoinSchemeDataModel(
      enrollmentId: json['enrollment_id'] is int
          ? json['enrollment_id'] as int
          : int.tryParse(json['enrollment_id']?.toString() ?? ''),
      schemeType: json['scheme_type'] as String?,
      monthlyInstallment: json['monthly_installment'] is num
          ? json['monthly_installment'] as num
          : num.tryParse(json['monthly_installment']?.toString() ?? ''),
      duration: json['duration'],
      nominee: json['nominee'] as String?,
      estimatedGoldPerMonth: json['estimated_gold_per_month'] as String?,
      firstInstallmentAmount: json['first_installment_amount'] is num
          ? json['first_installment_amount'] as num
          : num.tryParse(json['first_installment_amount']?.toString() ?? ''),
      currencySymbol: json['currency_symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
        'scheme_type': schemeType,
        'monthly_installment': monthlyInstallment,
        'duration': duration,
        'nominee': nominee,
        'estimated_gold_per_month': estimatedGoldPerMonth,
        'first_installment_amount': firstInstallmentAmount,
        'currency_symbol': currencySymbol,
      };
}

class JoinSchemeErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  JoinSchemeErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory JoinSchemeErrorModel.fromJson(Map<String, dynamic> json) {
    return JoinSchemeErrorModel(
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
