import 'package:nakshathra_scheme_app/config/app_config.dart';
import 'package:nakshathra_scheme_app/utils/enums.dart';

class UrlHelpers {
  static EnumBuildEnvironment get server => AppConfig.server;

  static String get baseURL {
    switch (server) {
      case EnumBuildEnvironment.live:
        return 'http://100.52.86.195:8069/';
      case EnumBuildEnvironment.uat:
        return 'http://100.52.86.195:8069/';
      case EnumBuildEnvironment.dg:
        return 'http://100.52.86.195:8069/';
    }
  }

  static String get key {
    switch (server) {
      case EnumBuildEnvironment.live:
        return '';
      case EnumBuildEnvironment.uat:
        return '';
      case EnumBuildEnvironment.dg:
        return '';
    }
  }

  static String get baseUrlApi {
    switch (server) {
      case EnumBuildEnvironment.live:
        return 'http://100.52.86.195:8069/api/';
      case EnumBuildEnvironment.uat:
        return 'http://100.52.86.195:8069/api/';
      case EnumBuildEnvironment.dg:
        return 'http://100.52.86.195:8069/api/';
    }
  }
}
