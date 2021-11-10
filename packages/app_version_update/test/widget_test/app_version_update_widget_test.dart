import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform/platform.dart';

setupWidget(WidgetTester tester, Function(BuildContext) onTriggered) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: FutureBuilder(
        builder: (BuildContext context, snapshot) => OutlinedButton(
          onPressed: () {
            onTriggered(context);
          },
          child: const Text(
            "Trigger",
            key: Key("trigger_app_version_popup"),
          ),
        ),
      ),
    ),
  ));
}

setCurrentMockVersion(String version) {
  PackageInfo.setMockInitialValues(
    appName: "appName",
    packageName: "packageName",
    version: version,
    buildNumber: "1",
    buildSignature: "buildSignature",
  );
}

const _triggerAppVersionPopupButtonKey = Key("trigger_app_version_popup");

void main() {
  testWidgets(
    'If user already has the latest version, popup must not be prompted',
    (WidgetTester tester) async {
      setCurrentMockVersion("2.0.0");
      final appVersion = AppVersionMetadata.fromJson({
        "ios": {
          "latestPublishedVersion": "2.0.0",
          "minRequiredAppVersion": "2.0.0",
        }
      });
      appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);

      final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
      final isThereAnyAvailableUpdate =
          await appVersion.isThereAnyUpdateAvailable();

      expect(isUserHasToForceUpdate, false);
      expect(isThereAnyAvailableUpdate, false);

      await setupWidget(
        tester,
        (context) => AppVersionPopup.showIfNeeded(
            appVersion: appVersion, context: context),
      );
      await tester.tap(find.byKey(_triggerAppVersionPopupButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppVersionPopup.appVersionPopupKey), findsNothing);
    },
  );

  testWidgets(
    'Force update option must appear & optional must not appear if user has a version lower than minimum required',
    (WidgetTester tester) async {
      setCurrentMockVersion("1.0.0");
      final appVersion = AppVersionMetadata.fromJson({
        "ios": {
          "latestPublishedVersion": "2.0.0",
          "minRequiredAppVersion": "2.0.0",
        }
      });
      appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);

      final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
      final isThereAnyAvailableUpdate =
          await appVersion.isThereAnyUpdateAvailable();

      expect(isUserHasToForceUpdate, true);
      expect(isThereAnyAvailableUpdate, true);

      await setupWidget(
        tester,
        (context) => AppVersionPopup.showIfNeeded(
            appVersion: appVersion, context: context),
      );
      await tester.tap(find.byKey(_triggerAppVersionPopupButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppVersionPopup.appVersionPopupKey), findsOneWidget);
      expect(find.byKey(AppVersionPopup.updateButtonKey), findsOneWidget);
      expect(find.byKey(AppVersionPopup.notNowButtonKey), findsNothing);
    },
  );

  testWidgets(
    'Force update option must not appear & optional must appear if user has a version greater than minimum required and lower than latest available',
    (WidgetTester tester) async {
      setCurrentMockVersion("1.6.0");
      final appVersion = AppVersionMetadata.fromJson({
        "configuration" : {
          "notNowButtonText" : "Not now",
          "updateButtonText" : "Update",
          "forceUpdateDescription" : "There is a new version, you can download if you want",
          "optionalUpdateDescription" : "There is a new version, you need to update to continue",
          "updateTitle" : "New Release is available"
        },
        "ios": {
          "latestPublishedVersion": "2.0.0",
          "minRequiredAppVersion": "1.5.0",
        }
      });
      appVersion.platform = FakePlatform(operatingSystem: Platform.iOS);

      final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();
      final isThereAnyAvailableUpdate =
          await appVersion.isThereAnyUpdateAvailable();

      expect(isUserHasToForceUpdate, false);
      expect(isThereAnyAvailableUpdate, true);

      await setupWidget(
        tester,
        (context) => AppVersionPopup.showIfNeeded(
            appVersion: appVersion, context: context),
      );
      await tester.tap(find.byKey(_triggerAppVersionPopupButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppVersionPopup.appVersionPopupKey), findsOneWidget);
      expect(find.byKey(AppVersionPopup.updateButtonKey), findsOneWidget);
      expect(find.byKey(AppVersionPopup.notNowButtonKey), findsOneWidget);

      expect(
        find.byKey(AppVersionPopup.updateTitleKey),
        appVersion.configuration?.updateTitle != null
            ? findsOneWidget
            : findsNothing,
      );

      expect(
        find.byKey(AppVersionPopup.optionalUpdateDescriptionKey),
        appVersion.configuration?.optionalUpdateDescription == null
            ? findsNothing
            : findsOneWidget,
      );

      expect(
        find.byKey(AppVersionPopup.forceUpdateDescriptionKey),
        findsNothing,
      );
    },
  );
}
