import '../../../utils/urls.dart';

class MySchemesRequestModel {
  final String jsonrpc;
  final Map<String, dynamic> params;

  MySchemesRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  factory MySchemesRequestModel.fromJson(Map<String, dynamic> json) {
    return MySchemesRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: (json['params'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params,
      };
}

class MySchemesResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final MySchemesResultModel? result;
  final MySchemesErrorModel? error;

  MySchemesResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory MySchemesResponseModel.fromJson(Map<String, dynamic> json) {
    return MySchemesResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? MySchemesResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? MySchemesResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? MySchemesErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? MySchemesErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class MySchemesResultModel {
  final String? status;
  final List<MySchemeDataModel>? data;

  MySchemesResultModel({
    this.status,
    this.data,
  });

  factory MySchemesResultModel.fromJson(Map<String, dynamic> json) {
    List<MySchemeDataModel>? schemesList;
    if (json['data'] != null && json['data'] is List) {
      schemesList = (json['data'] as List)
          .whereType<Map>()
          .map((item) => MySchemeDataModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return MySchemesResultModel(
      status: json['status'] as String?,
      data: schemesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class MySchemeDataModel {
  final int? id;
  final String? planName;
  final String? duration;
  final num? monthlyInstallment;
  final String? imageUrl;

  MySchemeDataModel({
    this.id,
    this.planName,
    this.duration,
    this.monthlyInstallment,
    this.imageUrl,
  });

  /// Resolves full image URL if image path is relative (e.g. /web/image/jewellery.scheme.enrollment/74869/image_1920)
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return null;
    final trimmed = imageUrl!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = urlBase.endsWith('/') ? urlBase.substring(0, urlBase.length - 1) : urlBase;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  String get formattedMonthlyInstallment {
    if (monthlyInstallment == null) return "₹0";
    return "₹${monthlyInstallment!.toInt()}";
  }

  factory MySchemeDataModel.fromJson(Map<String, dynamic> json) {
    return MySchemeDataModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      planName: json['plan_name'] as String?,
      duration: json['duration'] as String?,
      monthlyInstallment: json['monthly_installment'] is num
          ? json['monthly_installment'] as num
          : num.tryParse(json['monthly_installment']?.toString() ?? ''),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_name': planName,
        'duration': duration,
        'monthly_installment': monthlyInstallment,
        'image_url': imageUrl,
      };
}

class MySchemesErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  MySchemesErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory MySchemesErrorModel.fromJson(Map<String, dynamic> json) {
    return MySchemesErrorModel(
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
