// import 'dart:io';

import 'package:platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_version_update/app_version_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

setCurrentMockVersion(String version) {
  PackageInfo.setMockInitialValues(
    appName: "appName",
    packageName: "packageName",
    version: version,
    buildNumber: "1",
    buildSignature: "buildSignature",
  );
}

void main() {
  test("Mocking PackageInfo should work properly", () async {
    const appName = "appName";
    const packageName = "packageName";
    const version = "2.0.0";
    const buildNumber = "1";
    const buildSignature = "buildSignature";
    PackageInfo.setMockInitialValues(
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      buildSignature: buildSignature,
    );
    final packageInfo = await PackageInfo.fromPlatform();
    expect(packageInfo.appName, appName);
    expect(packageInfo.packageName, packageName);
    expect(packageInfo.version, version);
    expect(packageInfo.buildNumber, buildNumber);
    expect(packageInfo.buildSignature, buildSignature);
  });

  test('User must not be notified if already have latest version', () async {
    setCurrentMockVersion("2.0.0");
    final appVersion = AppVersionMetadata.fromJson({
      "ios": {
        "appId": "585027354",
        "latestPublishedVersion" : "2.0.0",
        "minRequiredAppVersion" : "2.0.0",
      }
    });
    appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);
    final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
    final isThereAnyAvailableUpdate =
        await appVersion.isThereAnyUpdateAvailable();
    expect(isUserHasToForceUpdate, false);
    expect(isThereAnyAvailableUpdate, false);
  });

  test('User must be notified if have a version lower than required with FORCE',
      () async {
    setCurrentMockVersion("1.0.0");
    final appVersion = AppVersionMetadata.fromJson({
      "ios": {
        "appId": "585027354",
        "latestPublishedVersion" : "2.0.0",
        "minRequiredAppVersion" : "2.0.0",
      }
    });
    appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);
    final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
    final isThereAnyAvailableUpdate =
        await appVersion.isThereAnyUpdateAvailable();
    expect(isUserHasToForceUpdate, true);
    expect(isThereAnyAvailableUpdate, true);
  });

  test('User should be notified if have a lower version with OPTIONAL',
      () async {
    setCurrentMockVersion("1.6.0");
    final appVersion = AppVersionMetadata.fromJson({
      "ios": {
        "appId": "585027354",
        "latestPublishedVersion" : "2.0.0",
        "minRequiredAppVersion" : "1.5.0",
      }
    });
    appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);
    final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
    final isThereAnyAvailableUpdate =
        await appVersion.isThereAnyUpdateAvailable();
    expect(isUserHasToForceUpdate, false);
    expect(isThereAnyAvailableUpdate, true);
  });
}
