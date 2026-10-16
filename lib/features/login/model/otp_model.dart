class SendOtpRequestModel {
  final String jsonrpc;
  final String method;
  final SendOtpParams params;
  final int id;

  const SendOtpRequestModel({
    this.jsonrpc = "2.0",
    this.method = "call",
    required this.params,
    this.id = 1,
  });

  Map<String, dynamic> toJson() => {
        "jsonrpc": jsonrpc,
        "method": method,
        "params": params.toJson(),
        "id": id,
      };
}

class SendOtpParams {
  final String phone;

  const SendOtpParams({required this.phone});

  Map<String, dynamic> toJson() => {
        "phone": phone,
      };
}

class SendOtpResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final SendOtpResultModel? result;
  final OtpErrorModel? error;

  const SendOtpResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result!.status.toLowerCase() == "success" || result!.status.toLowerCase() == "ok");

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    OtpErrorModel? error;
    SendOtpResultModel? result;

    if (json.containsKey('error') && json['error'] != null) {
      final err = json['error'];
      if (err is Map<String, dynamic>) {
        error = OtpErrorModel.fromJson(err);
      } else if (err is String) {
        error = OtpErrorModel(code: 400, message: err);
      }
    }

    if (json.containsKey('result') && json['result'] != null) {
      final res = json['result'];
      if (res is Map<String, dynamic>) {
        result = SendOtpResultModel.fromJson(res);
        if (result.status.toLowerCase() == 'error' || result.status.toLowerCase() == 'failed') {
          error ??= OtpErrorModel(
            code: 400,
            message: result.message ?? "Failed to send OTP",
          );
        }
      }
    }

    return SendOtpResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: result,
      error: error,
    );
  }
}

class SendOtpResultModel {
  final String status;
  final String? message;
  final String? otp;
  final String? phone;
  final int? userId;

  const SendOtpResultModel({
    required this.status,
    this.message,
    this.otp,
    this.phone,
    this.userId,
  });

  factory SendOtpResultModel.fromJson(Map<String, dynamic> json) {
    int? parsedUserId;
    if (json['user_id'] != null) {
      parsedUserId = int.tryParse(json['user_id'].toString());
    }

    return SendOtpResultModel(
      status: (json['status'] as String?) ?? "success",
      message: json['message'] as String?,
      otp: json['otp']?.toString(),
      phone: json['phone']?.toString(),
      userId: parsedUserId,
    );
  }
}

class VerifyOtpRequestModel {
  final String jsonrpc;
  final String method;
  final VerifyOtpParams params;
  final int id;

  const VerifyOtpRequestModel({
    this.jsonrpc = "2.0",
    this.method = "call",
    required this.params,
    this.id = 1,
  });

  Map<String, dynamic> toJson() => {
        "jsonrpc": jsonrpc,
        "method": method,
        "params": params.toJson(),
        "id": id,
      };
}

class VerifyOtpParams {
  final int userId;
  final String otp;

  const VerifyOtpParams({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "otp": otp,
      };
}

class VerifyOtpResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final VerifyOtpResultModel? result;
  final OtpErrorModel? error;

  const VerifyOtpResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result!.status.toLowerCase() == "success" ||
          result!.status.toLowerCase() == "ok" ||
          (result!.sessionId != null && result!.sessionId!.isNotEmpty));

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    OtpErrorModel? error;
    VerifyOtpResultModel? result;

    if (json.containsKey('error') && json['error'] != null) {
      final err = json['error'];
      if (err is Map<String, dynamic>) {
        error = OtpErrorModel.fromJson(err);
      } else if (err is String) {
        error = OtpErrorModel(code: 400, message: err);
      }
    }

    if (json.containsKey('result') && json['result'] != null) {
      final res = json['result'];
      if (res is Map<String, dynamic>) {
        result = VerifyOtpResultModel.fromJson(res);
        if (result.status.toLowerCase() == 'error' || result.status.toLowerCase() == 'failed') {
          error ??= OtpErrorModel(
            code: 400,
            message: result.message ?? "Failed to verify OTP",
          );
        }
      }
    }

    return VerifyOtpResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: result,
      error: error,
    );
  }
}

class VerifyOtpResultModel {
  final String status;
  final String? message;
  final String? sessionId;
  final OtpUserDataModel? data;

  const VerifyOtpResultModel({
    required this.status,
    this.message,
    this.sessionId,
    this.data,
  });

  factory VerifyOtpResultModel.fromJson(Map<String, dynamic> json) {
    OtpUserDataModel? userData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      userData = OtpUserDataModel.fromJson(json['data']);
    }

    return VerifyOtpResultModel(
      status: (json['status'] as String?) ?? "success",
      message: json['message'] as String?,
      sessionId: json['session_id'] as String?,
      data: userData,
    );
  }
}

class OtpUserDataModel {
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final int? employeeId;
  final String? employeeName;
  final String? jobPosition;

  const OtpUserDataModel({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.employeeId,
    this.employeeName,
    this.jobPosition,
  });

  factory OtpUserDataModel.fromJson(Map<String, dynamic> json) {
    int? parsedUserId;
    if (json['user_id'] != null) {
      parsedUserId = int.tryParse(json['user_id'].toString());
    }

    int? parsedEmployeeId;
    if (json['employee_id'] != null) {
      parsedEmployeeId = int.tryParse(json['employee_id'].toString());
    }

    return OtpUserDataModel(
      userId: parsedUserId,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      employeeId: parsedEmployeeId,
      employeeName: json['employee_name'] as String?,
      jobPosition: json['job_position'] as String?,
    );
  }
}

class OtpErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  const OtpErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory OtpErrorModel.fromJson(Map<String, dynamic> json) {
    String? msg = json['message']?.toString();
    if (json['data'] != null && json['data'] is Map && json['data']['message'] != null) {
      msg = json['data']['message']?.toString();
    }

    return OtpErrorModel(
      code: json['code'] is int ? json['code'] : int.tryParse(json['code']?.toString() ?? ''),
      message: msg ?? "An unexpected error occurred",
      data: json['data'],
    );
  }
}
