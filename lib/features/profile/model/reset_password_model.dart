// Models for api/scheme/reset-password

class ResetPasswordParams {
  final int userId;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "current_password": currentPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      };
}

class ResetPasswordRequestModel {
  final String jsonrpc;
  final String method;
  final ResetPasswordParams params;
  final int id;

  const ResetPasswordRequestModel({
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

class ResetPasswordResultModel {
  final String status;
  final String message;

  const ResetPasswordResultModel({
    required this.status,
    required this.message,
  });

  factory ResetPasswordResultModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResultModel(
      status: (json['status'] as String?) ?? "success",
      message: (json['message'] as String?) ?? "Password reset successfully.",
    );
  }
}

class ResetPasswordErrorModel {
  final int code;
  final String message;

  const ResetPasswordErrorModel({
    required this.code,
    required this.message,
  });
}

class ResetPasswordResponseModel {
  final ResetPasswordResultModel? result;
  final ResetPasswordErrorModel? error;

  const ResetPasswordResponseModel({this.result, this.error});

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result!.status == "success" || result!.status == "ok");

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      final err = json['error'];
      if (err is Map<String, dynamic>) {
        return ResetPasswordResponseModel(
          error: ResetPasswordErrorModel(
            code: (err['code'] as int?) ?? 400,
            message: (err['message'] as String?) ?? "Failed to reset password.",
          ),
        );
      } else if (err is String) {
        return ResetPasswordResponseModel(
          error: ResetPasswordErrorModel(
            code: 400,
            message: err,
          ),
        );
      }
    }
    if (json.containsKey('result')) {
      final res = json['result'];
      if (res is Map<String, dynamic>) {
        if (res['status'] == 'error' || res['status'] == 'failed') {
          return ResetPasswordResponseModel(
            error: ResetPasswordErrorModel(
              code: 400,
              message: (res['message'] as String?) ?? "Failed to reset password.",
            ),
            result: ResetPasswordResultModel.fromJson(res),
          );
        }
        return ResetPasswordResponseModel(
          result: ResetPasswordResultModel.fromJson(res),
        );
      }
    }
    return const ResetPasswordResponseModel();
  }
}
