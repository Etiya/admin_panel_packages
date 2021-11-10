import 'package:platform/platform.dart';
import 'package:package_info_plus/package_info_plus.dart';

/*
Sample JSON
{
  "appVersionUpdate" : {
    "android" : {
      "appId" : "com.iyaffle.kural",
      "latestPublishedVersion" : "1.0.0",
      "minRequiredAppVersion" : "1.0.0"
    },
    "configuration": {
      "notNowButtonText" : "Not now",
      "updateButtonText" : "Update",
      "forceUpdateDescription" : "There is a new version, you can download if you want",
      "optionalUpdateDescription" : "There is a new version, you need to update to continue",
      "updateTitle" : "New Release is available"
    },
    "ios" : {
      "appId" : "585027354",
      "latestPublishedVersion" : "2.3.0",
      "minRequiredAppVersion" : "2.0.0"
    }
  }
}
 */

class AppPlatform {
  AppPlatform({
    required this.appId,
    required this.latestPublishedVersion,
    required this.minRequiredAppVersion,
  });

  String? appId;
  String? latestPublishedVersion;
  String? minRequiredAppVersion;

  factory AppPlatform.fromJson(Map<String, dynamic>? json) => AppPlatform(
        appId: json?["appId"],
        latestPublishedVersion: json?["latestPublishedVersion"],
        minRequiredAppVersion: json?["minRequiredAppVersion"],
      );

  Map<String, dynamic> toJson() => {
        "appId": appId,
        "latestPublishedVersion": latestPublishedVersion,
        "minRequiredAppVersion": minRequiredAppVersion,
      };
}

class Configuration {
  Configuration({
    required this.notNowButtonText,
    required this.updateButtonText,
    required this.forceUpdateDescription,
    required this.optionalUpdateDescription,
    required this.updateTitle,
  });

  String? notNowButtonText;
  String? updateButtonText;
  String? forceUpdateDescription;
  String? optionalUpdateDescription;
  String? updateTitle;

  factory Configuration.fromJson(Map<String, dynamic>? json) => Configuration(
      notNowButtonText: json?["notNowButtonText"],
      updateButtonText: json?["updateButtonText"],
      forceUpdateDescription: json?["forceUpdateDescription"],
      optionalUpdateDescription: json?["optionalUpdateDescription"],
      updateTitle: json?["updateTitle"]);

  Map<String, dynamic> toJson() => {
        "notNowButtonText": notNowButtonText,
        "updateButtonText": updateButtonText,
        "forceUpdateDescription": forceUpdateDescription,
        "optionalUpdateDescription": optionalUpdateDescription,
        "updateTitle": updateTitle,
      };
}

class AppVersionMetadata {
  Configuration? configuration;
  AppPlatform? iosApp;
  AppPlatform? androidApp;

  AppVersionMetadata({
    required this.configuration,
    required this.iosApp,
    required this.androidApp,
  });

  factory AppVersionMetadata.fromJson(Map<String, dynamic>? json) =>
      AppVersionMetadata(
        configuration: json?["configuration"] != null
            ? Configuration.fromJson(
                Map<String, dynamic>.from(json?["configuration"]),
              )
            : null,
        iosApp: json?["ios"] != null
            ? AppPlatform.fromJson(
                Map<String, dynamic>.from(json?["ios"]),
              )
            : null,
        androidApp: json?["android"] != null
            ? AppPlatform.fromJson(
                Map<String, dynamic>.from(json?["android"]),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        "ios": iosApp?.toJson(),
        "android": androidApp?.toJson(),
        "configuration": configuration?.toJson()
      };

  Platform platform = const LocalPlatform();

  bool get isAndroid => platform.isAndroid;

  bool get isIOS => platform.isIOS;

  bool _isThereAnyAvailableUpdate = false;
  bool _isUserHasToForceUpdate = false;

  Future<bool> isUserHasToForceUpdate() async {
    await _calculate();
    return _isUserHasToForceUpdate;
  }

  Future<bool> isThereAnyUpdateAvailable() async {
    await _calculate();
    return _isThereAnyAvailableUpdate;
  }

  Future<void> _calculate() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int currentVersion =
        int.tryParse(packageInfo.version.trimNonNumeric) ?? -1;
    final int latestIOSVersion =
        int.tryParse(iosApp?.latestPublishedVersion?.trimNonNumeric ?? "0") ??
            -1;
    final int latestAndroidVersion = int.tryParse(
            androidApp?.latestPublishedVersion?.trimNonNumeric ?? "0") ??
        -1;

    _isUserHasToForceUpdate = false;
    _isThereAnyAvailableUpdate = false;

    if (isAndroid) {
      // Already have latest version
      if (currentVersion >= latestAndroidVersion) {
        return;
      }

      final int _minRequiredAndroidAppVersion = int.tryParse(
              androidApp?.minRequiredAppVersion?.trimNonNumeric ?? "0") ??
          -1;
      if (currentVersion < _minRequiredAndroidAppVersion) {
        _isUserHasToForceUpdate = true;
        _isThereAnyAvailableUpdate = true;
      } else if (currentVersion >= _minRequiredAndroidAppVersion &&
          currentVersion < latestAndroidVersion) {
        _isUserHasToForceUpdate = false;
        _isThereAnyAvailableUpdate = true;
      }
    } else if (isIOS) {
      // Already have latest version
      if (currentVersion >= latestIOSVersion) {
        return;
      }

      final int _minRequiredIOSAppVersion =
          int.tryParse(iosApp?.minRequiredAppVersion?.trimNonNumeric ?? "0") ??
              -1;
      if (currentVersion < _minRequiredIOSAppVersion) {
        _isUserHasToForceUpdate = true;
        _isThereAnyAvailableUpdate = true;
      } else if (currentVersion >= _minRequiredIOSAppVersion &&
          currentVersion < latestIOSVersion) {
        _isUserHasToForceUpdate = false;
        _isThereAnyAvailableUpdate = true;
      }
    }
  }
}

extension GetNumeric on String {
  String get trimNonNumeric => replaceAll(RegExp(r'[^\d]'), "");
}
