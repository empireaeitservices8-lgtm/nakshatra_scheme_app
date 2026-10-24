class SupportFaqRequestModel {
  final String jsonrpc;
  final String method;
  final dynamic id;
  final SupportFaqRequestParams params;

  SupportFaqRequestModel({
    this.jsonrpc = '2.0',
    this.method = 'call',
    this.id = 1,
    required this.params,
  });

  factory SupportFaqRequestModel.fromJson(Map<String, dynamic> json) {
    return SupportFaqRequestModel(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String? ?? 'call',
      id: json['id'] ?? 1,
      params: json['params'] != null
          ? SupportFaqRequestParams.fromJson(json['params'] as Map<String, dynamic>)
          : SupportFaqRequestParams(userId: 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'method': method,
        'params': params.toJson(),
        'id': id,
      };
}

class SupportFaqRequestParams {
  final int userId;

  SupportFaqRequestParams({required this.userId});

  factory SupportFaqRequestParams.fromJson(Map<String, dynamic> json) {
    return SupportFaqRequestParams(
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
      };
}

class SupportFaqResponseModel {
  final String? jsonrpc;
  final dynamic id;
  final SupportFaqResultModel? result;
  final SupportFaqErrorModel? error;

  SupportFaqResponseModel({
    this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess =>
      error == null &&
      result != null &&
      (result?.status?.toLowerCase() == 'success' || result?.data != null);

  factory SupportFaqResponseModel.fromJson(Map<String, dynamic> json) {
    return SupportFaqResponseModel(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'],
      result: json['result'] != null && json['result'] is Map<String, dynamic>
          ? SupportFaqResultModel.fromJson(json['result'] as Map<String, dynamic>)
          : (json['result'] != null && json['result'] is Map
              ? SupportFaqResultModel.fromJson(Map<String, dynamic>.from(json['result'] as Map))
              : null),
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? SupportFaqErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : (json['error'] != null && json['error'] is Map
              ? SupportFaqErrorModel.fromJson(Map<String, dynamic>.from(json['error'] as Map))
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

class SupportFaqResultModel {
  final String? status;
  final SupportFaqDataModel? data;

  SupportFaqResultModel({
    this.status,
    this.data,
  });

  factory SupportFaqResultModel.fromJson(Map<String, dynamic> json) {
    return SupportFaqResultModel(
      status: json['status'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SupportFaqDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] != null && json['data'] is Map
              ? SupportFaqDataModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}

class SupportFaqDataModel {
  final String? title;
  final String? subtitle;
  final SupportHotlineModel? supportHotline;
  final SupportHelpdeskModel? supportHelpdesk;
  final List<ContactChannelModel> contactChannels;
  final String? supportEmail;
  final String? supportPhone;
  final List<FaqItemModel> faqs;

  SupportFaqDataModel({
    this.title,
    this.subtitle,
    this.supportHotline,
    this.supportHelpdesk,
    this.contactChannels = const [],
    this.supportEmail,
    this.supportPhone,
    this.faqs = const [],
  });

  factory SupportFaqDataModel.fromJson(Map<String, dynamic> json) {
    List<ContactChannelModel> channels = [];
    if (json['contact_channels'] != null && json['contact_channels'] is List) {
      channels = (json['contact_channels'] as List)
          .whereType<Map>()
          .map((item) => ContactChannelModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<FaqItemModel> faqList = [];
    if (json['faqs'] != null && json['faqs'] is List) {
      faqList = (json['faqs'] as List)
          .whereType<Map>()
          .map((item) => FaqItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return SupportFaqDataModel(
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      supportHotline: json['support_hotline'] != null && json['support_hotline'] is Map
          ? SupportHotlineModel.fromJson(Map<String, dynamic>.from(json['support_hotline'] as Map))
          : null,
      supportHelpdesk: json['support_helpdesk'] != null && json['support_helpdesk'] is Map
          ? SupportHelpdeskModel.fromJson(Map<String, dynamic>.from(json['support_helpdesk'] as Map))
          : null,
      contactChannels: channels,
      supportEmail: json['support_email'] as String?,
      supportPhone: json['support_phone'] as String?,
      faqs: faqList,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'support_hotline': supportHotline?.toJson(),
        'support_helpdesk': supportHelpdesk?.toJson(),
        'contact_channels': contactChannels.map((e) => e.toJson()).toList(),
        'support_email': supportEmail,
        'support_phone': supportPhone,
        'faqs': faqs.map((e) => e.toJson()).toList(),
      };
}

class SupportHotlineModel {
  final String? title;
  final String? phoneNumber;
  final String? timing;
  final String? displayText;

  SupportHotlineModel({
    this.title,
    this.phoneNumber,
    this.timing,
    this.displayText,
  });

  factory SupportHotlineModel.fromJson(Map<String, dynamic> json) {
    return SupportHotlineModel(
      title: json['title'] as String?,
      phoneNumber: json['phone_number'] as String?,
      timing: json['timing'] as String?,
      displayText: json['display_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'phone_number': phoneNumber,
        'timing': timing,
        'display_text': displayText,
      };
}

class SupportHelpdeskModel {
  final String? title;
  final String? emailAddress;
  final String? displayText;

  SupportHelpdeskModel({
    this.title,
    this.emailAddress,
    this.displayText,
  });

  factory SupportHelpdeskModel.fromJson(Map<String, dynamic> json) {
    return SupportHelpdeskModel(
      title: json['title'] as String?,
      emailAddress: json['email_address'] as String?,
      displayText: json['display_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'email_address': emailAddress,
        'display_text': displayText,
      };
}

class ContactChannelModel {
  final String? type; // "phone" | "email"
  final String? title;
  final String? value;
  final String? phone;
  final String? email;
  final String? timing;

  ContactChannelModel({
    this.type,
    this.title,
    this.value,
    this.phone,
    this.email,
    this.timing,
  });

  bool get isPhone => type?.toLowerCase() == 'phone';
  bool get isEmail => type?.toLowerCase() == 'email';

  factory ContactChannelModel.fromJson(Map<String, dynamic> json) {
    return ContactChannelModel(
      type: json['type'] as String?,
      title: json['title'] as String?,
      value: json['value'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      timing: json['timing'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'value': value,
        'phone': phone,
        'email': email,
        'timing': timing,
      };
}

class FaqItemModel {
  final int? id;
  final String? question;
  final String? answer;

  FaqItemModel({
    this.id,
    this.question,
    this.answer,
  });

  factory FaqItemModel.fromJson(Map<String, dynamic> json) {
    return FaqItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      question: json['question'] as String?,
      answer: json['answer'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
      };
}

class SupportFaqErrorModel {
  final int? code;
  final String? message;
  final dynamic data;

  SupportFaqErrorModel({
    this.code,
    this.message,
    this.data,
  });

  factory SupportFaqErrorModel.fromJson(Map<String, dynamic> json) {
    return SupportFaqErrorModel(
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
