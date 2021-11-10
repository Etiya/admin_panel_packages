import 'package:flutter/material.dart';

import '../maintenance_mode.dart';
import '../src/maintenance_mode_screen.dart';

class MaintenanceModeManager {
  MaintenanceModeManager._internal();

  static final MaintenanceModeManager shared =
      MaintenanceModeManager._internal();

  bool _isScreenActive = false;

  showIfNeeded({
    required MaintenanceMode maintenanceMode,
    required BuildContext context,
  }) async {
    print("* isScreenActive: $_isScreenActive, isMaintenanceEnabled: ${maintenanceMode.enabled}");
    if (!maintenanceMode.enabled) {
      if (_isScreenActive) {
        Navigator.of(context).pop();
        _isScreenActive = false;
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaintenanceModeScreen(maintenanceMode: maintenanceMode),
      ),
    );
    _isScreenActive = true;
    print("** isScreenActive: $_isScreenActive, isMaintenanceEnabled: ${maintenanceMode.enabled}");
  }
}

