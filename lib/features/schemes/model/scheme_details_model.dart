import '../../../utils/urls.dart';

class SchemeDetailsRequestModel {
  final String jsonrpc;
  final SchemeDetailsParams params;

  SchemeDetailsRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  factory SchemeDetailsRequestModel.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      params: json['params'] != null
          ? SchemeDetailsParams.fromJson(json['params'] as Map<String, dynamic>)
          : SchemeDetailsParams(enrollmentId: 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params.toJson(),
      };
}

class SchemeDetailsParams {
  final int enrollmentId;

  SchemeDetailsParams({required this.enrollmentId});

  factory SchemeDetailsParams.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsParams(
      enrollmentId: json['enrollment_id'] is int
          ? json['enrollment_id'] as int
          : int.tryParse(json['enrollment_id']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
      };
}

class SchemeDetailsResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final SchemeDetailsResultModel? result;
  final SchemeDetailsErrorModel? error;

  SchemeDetailsResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      result?.status?.toLowerCase() == 'success';

  factory SchemeDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? SchemeDetailsResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? SchemeDetailsResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? SchemeDetailsErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? SchemeDetailsErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class SchemeDetailsResultModel {
  final String? status;
  final SchemeDetailsDataModel? data;

  SchemeDetailsResultModel({
    this.status,
    this.data,
  });

  factory SchemeDetailsResultModel.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsResultModel(
      status: json['status'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SchemeDetailsDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? SchemeDetailsDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}

class SchemeDetailsDataModel {
  final int? enrollmentId;
  final String? planName;
  final String? imageUrl;
  final num? totalInvested;
  final num? installmentDue;
  final String? nextDueMonth;
  final int? paidCount;
  final int? totalCount;
  final String? progressText;
  final String? currencySymbol;
  final List<SchemeTimelineItemModel> timeline;

  SchemeDetailsDataModel({
    this.enrollmentId,
    this.planName,
    this.imageUrl,
    this.totalInvested,
    this.installmentDue,
    this.nextDueMonth,
    this.paidCount,
    this.totalCount,
    this.progressText,
    this.currencySymbol,
    this.timeline = const [],
  });

  /// Resolves full image URL if image path is relative
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

  double get progressFraction {
    if (totalCount == null || totalCount == 0) return 0.0;
    final count = paidCount ?? 0;
    return (count / totalCount!).clamp(0.0, 1.0);
  }

  factory SchemeDetailsDataModel.fromJson(Map<String, dynamic> json) {
    List<SchemeTimelineItemModel> timelineItems = [];
    if (json['timeline'] != null && json['timeline'] is List) {
      timelineItems = (json['timeline'] as List)
          .whereType<Map>()
          .map((item) => SchemeTimelineItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return SchemeDetailsDataModel(
      enrollmentId: json['enrollment_id'] is int
          ? json['enrollment_id'] as int
          : int.tryParse(json['enrollment_id']?.toString() ?? ''),
      planName: json['plan_name'] as String?,
      imageUrl: json['image_url'] as String?,
      totalInvested: json['total_invested'] is num
          ? json['total_invested'] as num
          : num.tryParse(json['total_invested']?.toString() ?? ''),
      installmentDue: json['installment_due'] is num
          ? json['installment_due'] as num
          : num.tryParse(json['installment_due']?.toString() ?? ''),
      nextDueMonth: json['next_due_month'] as String?,
      paidCount: json['paid_count'] is int
          ? json['paid_count'] as int
          : int.tryParse(json['paid_count']?.toString() ?? ''),
      totalCount: json['total_count'] is int
          ? json['total_count'] as int
          : int.tryParse(json['total_count']?.toString() ?? ''),
      progressText: json['progress_text'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      timeline: timelineItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
        'plan_name': planName,
        'image_url': imageUrl,
        'total_invested': totalInvested,
        'installment_due': installmentDue,
        'next_due_month': nextDueMonth,
        'paid_count': paidCount,
        'total_count': totalCount,
        'progress_text': progressText,
        'currency_symbol': currencySymbol,
        'timeline': timeline.map((e) => e.toJson()).toList(),
      };
}

class SchemeTimelineItemModel {
  final String? period;
  final String? date;
  final String? status;
  final String? statusTag;
  final num? amount;
  final String? currencySymbol;
  final bool isActiveMonth;
  final bool canPay;
  final String? actionLabel;

  SchemeTimelineItemModel({
    this.period,
    this.date,
    this.status,
    this.statusTag,
    this.amount,
    this.currencySymbol,
    this.isActiveMonth = false,
    this.canPay = false,
    this.actionLabel,
  });

  bool get isPaid => (status ?? statusTag)?.toLowerCase() == 'paid';
  bool get isNotPaid => (status ?? statusTag)?.toLowerCase() == 'not paid';
  bool get isUpcoming => (status ?? statusTag)?.toLowerCase() == 'upcoming';

  factory SchemeTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return SchemeTimelineItemModel(
      period: json['period'] as String?,
      date: json['date'] as String?,
      status: json['status'] as String?,
      statusTag: json['status_tag'] as String?,
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse(json['amount']?.toString() ?? ''),
      currencySymbol: json['currency_symbol'] as String?,
      isActiveMonth: json['is_active_month'] as bool? ?? false,
      canPay: json['can_pay'] as bool? ?? false,
      actionLabel: json['action_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'date': date,
        'status': status,
        'status_tag': statusTag,
        'amount': amount,
        'currency_symbol': currencySymbol,
        'is_active_month': isActiveMonth,
        'can_pay': canPay,
        'action_label': actionLabel,
      };
}

class SchemeDetailsErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  SchemeDetailsErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory SchemeDetailsErrorModel.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsErrorModel(
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
