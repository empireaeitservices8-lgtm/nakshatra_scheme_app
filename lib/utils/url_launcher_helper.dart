import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_build_methods.dart';

class UrlLauncherHelper {
  /// Launches the native phone caller with the given phone number
  static Future<void> launchPhoneCaller(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      showToast("Phone number not available");
      return;
    }

    final trimmed = phoneNumber.trim();
    // Clean string for tel URI: keep '+' and digits
    final cleaned = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri telUri = Uri(
      scheme: 'tel',
      path: cleaned.isNotEmpty ? cleaned : trimmed,
    );

    try {
      final bool launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback try platformDefault
        final bool retryLaunched = await launchUrl(telUri);
        if (!retryLaunched) {
          showToast("Unable to open phone dialer for $trimmed");
        }
      }
    } catch (e) {
      debugPrint("❌ [UrlLauncherHelper] Error launching caller: $e");
      showToast("Could not launch phone dialer");
    }
  }

  /// Launches the native email app with the given email address, subject, and body
  static Future<void> launchEmailClient(
    String? emailAddress, {
    String? subject,
    String? body,
  }) async {
    if (emailAddress == null || emailAddress.trim().isEmpty) {
      showToast("Email address not available");
      return;
    }

    final trimmed = emailAddress.trim();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: trimmed,
      query: _encodeQueryParameters({
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      }),
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        final bool retryLaunched = await launchUrl(emailUri);
        if (!retryLaunched) {
          showToast("Unable to open email client for $trimmed");
        }
      }
    } catch (e) {
      debugPrint("❌ [UrlLauncherHelper] Error launching email: $e");
      showToast("Could not open email application");
    }
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
