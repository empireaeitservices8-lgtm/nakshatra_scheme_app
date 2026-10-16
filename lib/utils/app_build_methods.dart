
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'extensions.dart';

Widget buildCachedNetworkImage(
  String? url, {
  double? height,
  BoxFit fit = BoxFit.cover,
  BoxFit? placeholderFit,
  double? width,
  EdgeInsets placeholderPadding = EdgeInsets.zero,
}) {
  placeholderFit ??= fit;
  return CachedNetworkImage(
    imageUrl: url ?? "",
    height: height,
    width: width,
    fit: fit,
    placeholder: (context, url) => Padding(
      padding: placeholderPadding,
      // child: SvgPicture.asset(
      //   'place_holder'.asAssetSvg(),
      //   fit: placeholderFit!,
      // ),
      child: const SizedBox(),
    ),
    errorWidget: (
      context,
      url,
      error,
    ) =>
        Padding(
      padding: placeholderPadding,
      child: Image.asset('lock_image.png'.asAssetImg()),
    ),
  );
}

double rssiTosignalStrength([double rssi = 0.0]) {
  double minRssi = -100; // Reference RSSI value for minimum signal strength
  double maxRssi = 0; // Reference RSSI value for maximum signal strength
  double minSignalStrength = 0; // Minimum signal strength value
  double maxSignalStrength = 1; // Maximum signal strength value

  double signalStrength = ((rssi - minRssi) *
          (maxSignalStrength - minSignalStrength) /
          (maxRssi - minRssi)) +
      minSignalStrength;

  return (signalStrength); // Output: 0.78
}

void showToast(
  String msg, {
  ToastGravity? gravity,
  Color? backgroundColor,
  Color? textColor,
  double? fontSize,
  Toast? toastLength,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength ?? Toast.LENGTH_SHORT,
    gravity: gravity ?? ToastGravity.BOTTOM,
    backgroundColor: backgroundColor ?? const Color(0xFF101826),
    textColor: textColor ?? const Color(0xFFE5B869),
    fontSize: fontSize ?? 13.5,
  );
}

printApiResponse(object, {String? head = "Head"}) {
  String coloredHead = '\x1B[32m $head \x1B[0m \x1B[31m ->>>> \x1B[0m';
  if (kDebugMode) {
    debugPrint("$coloredHead"
        "${'\x1B[32m $object \x1B[0m'}");
  }
}

/// Restricts input to valid Indian mobile number: only 10 digits starting with 6, 7, 8, or 9
class IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    // Strip all non-digits
    final cleanDigits = text.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) {
      return const TextEditingValue();
    }

    // Indian mobile numbers must start with 6, 7, 8, or 9
    final firstChar = cleanDigits[0];
    if (!['6', '7', '8', '9'].contains(firstChar)) {
      return oldValue; // Disallow entering 0, 1, 2, 3, 4, 5 as first digit
    }

    // Limit to 10 digits
    final limited =
        cleanDigits.length > 10 ? cleanDigits.substring(0, 10) : cleanDigits;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Validates whether a phone number is a valid 10-digit Indian mobile number
bool isValidIndianPhoneNumber(String? phone) {
  if (phone == null) return false;
  final clean = phone.trim();
  if (clean.length != 10) return false;
  // Must start with 6, 7, 8, or 9 and be 10 digits
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) return false;
  // Reject repetitive numbers like 0000000000, 9999999999, etc.
  if (RegExp(r'^(\d)\1{9}$').hasMatch(clean)) return false;
  return true;
}

