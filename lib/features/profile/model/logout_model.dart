import 'package:json_annotation/json_annotation.dart';

part 'logout_model.g.dart';

@JsonSerializable()
class LogoutRequestModel {
  @JsonKey(defaultValue: '2.0')
  final String jsonrpc;
  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> params;

  LogoutRequestModel({
    this.jsonrpc = '2.0',
    this.params = const <String, dynamic>{},
  });

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestModelToJson(this);
}

@JsonSerializable()
class LogoutResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final LogoutResultModel? result;
  final LogoutErrorModel? error;

  LogoutResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' ||
          (result?.message?.isNotEmpty ?? false));

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResponseModelToJson(this);
}

@JsonSerializable()
class LogoutResultModel {
  final String? status;
  final String? message;

  LogoutResultModel({
    this.status,
    this.message,
  });

  factory LogoutResultModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResultModelToJson(this);
}

@JsonSerializable()
class LogoutErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  LogoutErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory LogoutErrorModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutErrorModelToJson(this);
}
