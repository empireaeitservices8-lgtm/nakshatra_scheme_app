// Models for api/scheme/transaction-receipts

// --- Request ---------------------------------------------------------------
class TransactionReceiptsRequestModel {
  final String jsonrpc;
  final String method;
  final Map<String, dynamic> params;
  final int id;

  const TransactionReceiptsRequestModel({
    this.jsonrpc = "2.0",
    this.method = "call",
    this.params = const {},
    this.id = 1,
  });

  Map<String, dynamic> toJson() => {
        "jsonrpc": jsonrpc,
        "method": method,
        "params": params,
        "id": id,
      };
}

// --- Receipt Item -----------------------------------------------------------
class TransactionReceiptItem {
  final int? id;
  final String title;
  final String paidDate;
  final String amount;
  final double amountRaw;
  final String type; // "credit" | "debit"
  final String? downloadUrl;

  const TransactionReceiptItem({
    this.id,
    required this.title,
    required this.paidDate,
    required this.amount,
    required this.amountRaw,
    required this.type,
    this.downloadUrl,
  });

  bool get isCredit => type == "credit";

  factory TransactionReceiptItem.fromJson(Map<String, dynamic> json) {
    return TransactionReceiptItem(
      id: json['id'] as int?,
      title: (json['title'] as String?) ?? "Transaction",
      paidDate: (json['paid_date'] as String?) ?? "",
      amount: (json['amount'] as String?) ?? "",
      amountRaw: ((json['amount_raw'] as num?) ?? 0).toDouble(),
      type: (json['type'] as String?) ?? "credit",
      downloadUrl: json['download_url'] as String?,
    );
  }
}

// --- Result -----------------------------------------------------------------
class TransactionReceiptsResultModel {
  final String status;
  final List<TransactionReceiptItem> data;

  const TransactionReceiptsResultModel({
    required this.status,
    required this.data,
  });

  factory TransactionReceiptsResultModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<TransactionReceiptItem> items = [];
    if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => TransactionReceiptItem.fromJson(e))
          .toList();
    }
    return TransactionReceiptsResultModel(
      status: (json['status'] as String?) ?? "success",
      data: items,
    );
  }
}

// --- Error -------------------------------------------------------------------
class TransactionReceiptsErrorModel {
  final int code;
  final String message;

  const TransactionReceiptsErrorModel({
    required this.code,
    required this.message,
  });
}

// --- Response ----------------------------------------------------------------
class TransactionReceiptsResponseModel {
  final TransactionReceiptsResultModel? result;
  final TransactionReceiptsErrorModel? error;

  const TransactionReceiptsResponseModel({this.result, this.error});

  bool get isSuccess =>
      error == null && result != null && result!.status == "success";

  factory TransactionReceiptsResponseModel.fromJson(
      Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      final err = json['error'] as Map<String, dynamic>? ?? {};
      return TransactionReceiptsResponseModel(
        error: TransactionReceiptsErrorModel(
          code: (err['code'] as int?) ?? 500,
          message: (err['message'] as String?) ?? "Unknown error",
        ),
      );
    }
    if (json.containsKey('result')) {
      final resultData = json['result'];
      if (resultData is Map<String, dynamic>) {
        return TransactionReceiptsResponseModel(
          result: TransactionReceiptsResultModel.fromJson(resultData),
        );
      }
    }
    return const TransactionReceiptsResponseModel();
  }
}
