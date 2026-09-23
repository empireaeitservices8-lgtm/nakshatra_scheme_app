import '../../../utils/urls.dart';

class PopularPlansRequestModel {
  final String jsonrpc;
  final Map<String, dynamic> params;

  PopularPlansRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  factory PopularPlansRequestModel.fromJson(Map<String, dynamic> json) {
    return PopularPlansRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: (json['params'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params,
      };
}

class PopularPlansResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final PopularPlansResultModel? result;
  final PopularPlansErrorModel? error;

  PopularPlansResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory PopularPlansResponseModel.fromJson(Map<String, dynamic> json) {
    return PopularPlansResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? PopularPlansResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? PopularPlansResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? PopularPlansErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? PopularPlansErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class PopularPlansResultModel {
  final String? status;
  final List<PopularPlanDataModel>? data;

  PopularPlansResultModel({
    this.status,
    this.data,
  });

  factory PopularPlansResultModel.fromJson(Map<String, dynamic> json) {
    List<PopularPlanDataModel>? plansList;
    if (json['data'] != null && json['data'] is List) {
      plansList = (json['data'] as List)
          .whereType<Map>()
          .map((item) => PopularPlanDataModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return PopularPlansResultModel(
      status: json['status'] as String?,
      data: plansList,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class PopularPlanDataModel {
  final int? id;
  final String? title;
  final String? description;
  final String? type; // "fixed_weight", "maturity_bonus", etc.
  final String? imageUrl;
  final String? actionLabel;

  PopularPlanDataModel({
    this.id,
    this.title,
    this.description,
    this.type,
    this.imageUrl,
    this.actionLabel,
  });

  /// Resolves full image URL if image path is relative (e.g. /web/image/product.template/1/image_1920)
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

  bool get isFixedWeight => type == 'fixed_weight';
  bool get isMaturityBonus => type == 'maturity_bonus';

  factory PopularPlanDataModel.fromJson(Map<String, dynamic> json) {
    return PopularPlanDataModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      imageUrl: json['image_url'] as String?,
      actionLabel: json['action_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'image_url': imageUrl,
        'action_label': actionLabel,
      };
}

class PopularPlansErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  PopularPlansErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory PopularPlansErrorModel.fromJson(Map<String, dynamic> json) {
    return PopularPlansErrorModel(
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
