import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class AppVersionPopup {
  static const appVersionPopupKey = Key("app_version_popup");
  static const updateButtonKey = Key("app_version_force_update_btn");
  static const notNowButtonKey = Key("app_version_optional_update_btn");
  static const updateTitleKey = Key("app_version_update_title");
  static const optionalUpdateDescriptionKey = Key("app_version_optional_update_description");
  static const forceUpdateDescriptionKey = Key("app_version_force_update_description");

  static showIfNeeded({
    required AppVersionMetadata appVersion,
    required BuildContext context,
  }) async {
    final isThereAnyUpdateAvailable =
        await appVersion.isThereAnyUpdateAvailable();
    final isUserHasToForceUpdate = await appVersion.isUserHasToForceUpdate();

    if (!isThereAnyUpdateAvailable) {
      return;
    }

    showDialog(
      barrierDismissible: !isUserHasToForceUpdate,
      context: context,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(!isUserHasToForceUpdate),
        child: Dialog(
          key: appVersionPopupKey,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appVersion.configuration?.updateTitle != null)
                    ...[
                      Text(
                        appVersion.configuration?.updateTitle ?? "",
                        key: updateTitleKey,
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      const Divider()
                    ],
                  if (isUserHasToForceUpdate)
                    Text(
                      appVersion.configuration?.forceUpdateDescription ?? "",
                      key: forceUpdateDescriptionKey,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  if (!isUserHasToForceUpdate)
                    Text(
                      appVersion.configuration?.optionalUpdateDescription ?? "",
                      key: optionalUpdateDescriptionKey,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  Row(
                    children: [
                      if (!isUserHasToForceUpdate)
                        TextButton(
                          key: notNowButtonKey,
                          onPressed: () {},
                          child: Text(
                            appVersion.configuration?.notNowButtonText ?? "Not now",
                          ),
                        ),
                      TextButton(
                        key: updateButtonKey,
                        onPressed: () {
                          LaunchReview.launch(
                            androidAppId: appVersion.androidApp?.appId,
                            iOSAppId: appVersion.iosApp?.appId,
                          );
                        },
                        child: Text(
                          appVersion.configuration?.updateButtonText ?? "Update",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}