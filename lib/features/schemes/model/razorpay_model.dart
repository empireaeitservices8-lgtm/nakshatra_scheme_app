// ==========================================
// 1. RAZORPAY CONFIG MODELS
// ==========================================

class RazorpayConfigRequestModel {
  final String jsonrpc;
  final Map<String, dynamic> params;

  RazorpayConfigRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params,
      };
}

class RazorpayConfigResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final RazorpayConfigResultModel? result;
  final RazorpayErrorModel? error;

  RazorpayConfigResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' || (result?.keyId != null && result!.keyId!.isNotEmpty));

  factory RazorpayConfigResponseModel.fromJson(Map<String, dynamic> json) {
    return RazorpayConfigResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? RazorpayConfigResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? RazorpayConfigResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? RazorpayErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? RazorpayErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class RazorpayConfigResultModel {
  final String? status;
  final String? keyId;
  final String? currency;
  final String? companyName;
  final String? description;
  final bool? enabled;

  RazorpayConfigResultModel({
    this.status,
    this.keyId,
    this.currency,
    this.companyName,
    this.description,
    this.enabled,
  });

  factory RazorpayConfigResultModel.fromJson(Map<String, dynamic> json) {
    return RazorpayConfigResultModel(
      status: json['status'] as String?,
      keyId: (json['key_id'] ?? json['key']) as String?,
      currency: json['currency'] as String?,
      companyName: (json['company_name'] ?? json['name']) as String?,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'key_id': keyId,
        'currency': currency,
        'company_name': companyName,
        'description': description,
        'enabled': enabled,
      };
}

// ==========================================
// 2. RAZORPAY CREATE ORDER MODELS
// ==========================================

class RazorpayCreateOrderRequestModel {
  final String jsonrpc;
  final RazorpayCreateOrderParams params;

  RazorpayCreateOrderRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params.toJson(),
      };
}

class RazorpayCreateOrderParams {
  final String ticketNumber;
  final double amount;

  RazorpayCreateOrderParams({
    required this.ticketNumber,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'ticket_number': ticketNumber,
        'amount': amount,
      };
}

class RazorpayCreateOrderResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final RazorpayCreateOrderResultModel? result;
  final RazorpayErrorModel? error;

  RazorpayCreateOrderResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' || result?.data != null);

  factory RazorpayCreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return RazorpayCreateOrderResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? RazorpayCreateOrderResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? RazorpayCreateOrderResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? RazorpayErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? RazorpayErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class RazorpayCreateOrderResultModel {
  final String? status;
  final String? message;
  final RazorpayOrderDataModel? data;

  RazorpayCreateOrderResultModel({
    this.status,
    this.message,
    this.data,
  });

  factory RazorpayCreateOrderResultModel.fromJson(Map<String, dynamic> json) {
    return RazorpayCreateOrderResultModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RazorpayOrderDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? RazorpayOrderDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class RazorpayOrderDataModel {
  final String? orderId;
  final num? amount;
  final num? amountInPaise;
  final String? currency;
  final String? keyId;
  final String? receipt;
  final int? enrollmentId;
  final String? enrollmentName;
  final String? ticketNumber;
  final int? installmentId;
  final String? installmentDate;
  final bool? isTestMode;
  final RazorpayCustomerModel? customer;

  RazorpayOrderDataModel({
    this.orderId,
    this.amount,
    this.amountInPaise,
    this.currency,
    this.keyId,
    this.receipt,
    this.enrollmentId,
    this.enrollmentName,
    this.ticketNumber,
    this.installmentId,
    this.installmentDate,
    this.isTestMode,
    this.customer,
  });

  factory RazorpayOrderDataModel.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderDataModel(
      orderId: json['order_id'] as String?,
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse(json['amount']?.toString() ?? ''),
      amountInPaise: json['amount_in_paise'] is num
          ? json['amount_in_paise'] as num
          : num.tryParse(json['amount_in_paise']?.toString() ?? ''),
      currency: json['currency'] as String?,
      keyId: json['key_id'] as String?,
      receipt: json['receipt'] as String?,
      enrollmentId: json['enrollment_id'] is int
          ? json['enrollment_id'] as int
          : int.tryParse(json['enrollment_id']?.toString() ?? ''),
      enrollmentName: json['enrollment_name'] as String?,
      ticketNumber: json['ticket_number']?.toString(),
      installmentId: json['installment_id'] is int
          ? json['installment_id'] as int
          : int.tryParse(json['installment_id']?.toString() ?? ''),
      installmentDate: json['installment_date'] as String?,
      isTestMode: json['is_test_mode'] as bool? ?? false,
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? RazorpayCustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : (json['customer'] != null && json['customer'] is Map
              ? RazorpayCustomerModel.fromJson(Map<String, dynamic>.from(json['customer'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'amount': amount,
        'amount_in_paise': amountInPaise,
        'currency': currency,
        'key_id': keyId,
        'receipt': receipt,
        'enrollment_id': enrollmentId,
        'enrollment_name': enrollmentName,
        'ticket_number': ticketNumber,
        'installment_id': installmentId,
        'installment_date': installmentDate,
        'is_test_mode': isTestMode,
        'customer': customer?.toJson(),
      };
}

class RazorpayCustomerModel {
  final String? name;
  final String? email;
  final String? phone;

  RazorpayCustomerModel({
    this.name,
    this.email,
    this.phone,
  });

  factory RazorpayCustomerModel.fromJson(Map<String, dynamic> json) {
    return RazorpayCustomerModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

// ==========================================
// 3. RAZORPAY VERIFY PAYMENT MODELS
// ==========================================

class RazorpayVerifyPaymentRequestModel {
  final String jsonrpc;
  final RazorpayVerifyPaymentParams params;

  RazorpayVerifyPaymentRequestModel({
    this.jsonrpc = '2.0',
    required this.params,
  });

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'params': params.toJson(),
      };
}

class RazorpayVerifyPaymentParams {
  final String ticketNumber;
  final int installmentId;
  final String orderId;
  final String paymentId;
  final String signature;
  final double amount;

  RazorpayVerifyPaymentParams({
    required this.ticketNumber,
    required this.installmentId,
    required this.orderId,
    required this.paymentId,
    required this.signature,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'ticket_number': ticketNumber,
        'installment_id': installmentId,
        'order_id': orderId,
        'payment_id': paymentId,
        'signature': signature,
        'amount': amount,
      };
}

class RazorpayVerifyPaymentResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final RazorpayVerifyPaymentResultModel? result;
  final RazorpayErrorModel? error;

  RazorpayVerifyPaymentResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' || result?.data != null);

  factory RazorpayVerifyPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return RazorpayVerifyPaymentResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? RazorpayVerifyPaymentResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? RazorpayVerifyPaymentResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? RazorpayErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? RazorpayErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class RazorpayVerifyPaymentResultModel {
  final String? status;
  final String? message;
  final RazorpayVerifyDataModel? data;

  RazorpayVerifyPaymentResultModel({
    this.status,
    this.message,
    this.data,
  });

  factory RazorpayVerifyPaymentResultModel.fromJson(Map<String, dynamic> json) {
    return RazorpayVerifyPaymentResultModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RazorpayVerifyDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? RazorpayVerifyDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class RazorpayVerifyDataModel {
  final int? enrollmentId;
  final String? enrollmentName;
  final String? ticketNumber;
  final String? partnerName;
  final int? installmentId;
  final String? installmentDate;
  final num? amountPaid;
  final String? state;
  final String? stateDisplay;
  final String? transactionId;
  final String? orderId;
  final String? journal;
  final num? totalPaid;
  final num? balanceAmount;
  final int? paidCount;
  final int? totalCount;
  final bool? isCompleted;

  RazorpayVerifyDataModel({
    this.enrollmentId,
    this.enrollmentName,
    this.ticketNumber,
    this.partnerName,
    this.installmentId,
    this.installmentDate,
    this.amountPaid,
    this.state,
    this.stateDisplay,
    this.transactionId,
    this.orderId,
    this.journal,
    this.totalPaid,
    this.balanceAmount,
    this.paidCount,
    this.totalCount,
    this.isCompleted,
  });

  factory RazorpayVerifyDataModel.fromJson(Map<String, dynamic> json) {
    return RazorpayVerifyDataModel(
      enrollmentId: json['enrollment_id'] is int
          ? json['enrollment_id'] as int
          : int.tryParse(json['enrollment_id']?.toString() ?? ''),
      enrollmentName: json['enrollment_name'] as String?,
      ticketNumber: json['ticket_number']?.toString(),
      partnerName: json['partner_name'] as String?,
      installmentId: json['installment_id'] is int
          ? json['installment_id'] as int
          : int.tryParse(json['installment_id']?.toString() ?? ''),
      installmentDate: json['installment_date'] as String?,
      amountPaid: json['amount_paid'] is num
          ? json['amount_paid'] as num
          : num.tryParse(json['amount_paid']?.toString() ?? ''),
      state: json['state'] as String?,
      stateDisplay: json['state_display'] as String?,
      transactionId: (json['transaction_id'] ?? json['payment_id']) as String?,
      orderId: json['order_id'] as String?,
      journal: json['journal'] as String?,
      totalPaid: json['total_paid'] is num
          ? json['total_paid'] as num
          : num.tryParse(json['total_paid']?.toString() ?? ''),
      balanceAmount: json['balance_amount'] is num
          ? json['balance_amount'] as num
          : num.tryParse(json['balance_amount']?.toString() ?? ''),
      paidCount: json['paid_count'] is int
          ? json['paid_count'] as int
          : int.tryParse(json['paid_count']?.toString() ?? ''),
      totalCount: json['total_count'] is int
          ? json['total_count'] as int
          : int.tryParse(json['total_count']?.toString() ?? ''),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
        'enrollment_name': enrollmentName,
        'ticket_number': ticketNumber,
        'partner_name': partnerName,
        'installment_id': installmentId,
        'installment_date': installmentDate,
        'amount_paid': amountPaid,
        'state': state,
        'state_display': stateDisplay,
        'transaction_id': transactionId,
        'order_id': orderId,
        'journal': journal,
        'total_paid': totalPaid,
        'balance_amount': balanceAmount,
        'paid_count': paidCount,
        'total_count': totalCount,
        'is_completed': isCompleted,
      };
}

class RazorpayErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  RazorpayErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory RazorpayErrorModel.fromJson(Map<String, dynamic> json) {
    return RazorpayErrorModel(
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
