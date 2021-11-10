import 'package:flutter/material.dart';

import '../maintenance_mode.dart';

class MaintenanceModeScreen extends StatelessWidget {
  static const maintenanceModeScreenKey = Key("__maintenance_screen_key__");
  static const maintenanceDescriptionKey = Key("__maintenance_screen_mode_description__");

  const MaintenanceModeScreen({
    Key? key,
    required this.maintenanceMode,
  }) : super(key: key);

  final MaintenanceMode maintenanceMode;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(!maintenanceMode.enabled),
      child: Scaffold(
        body: SizedBox(
          key: maintenanceModeScreenKey,
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 120,),
                const SizedBox(height: 16,),
                Text(
                  maintenanceMode.maintenanceDescription,
                  key: maintenanceDescriptionKey,
                  style: Theme.of(context).textTheme.headline6,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
