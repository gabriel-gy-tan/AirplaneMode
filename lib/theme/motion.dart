import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';

/// Motion helpers that respect the reduce-motion setting.
///
/// Returns [ms] as a duration, or zero when reduce motion is enabled so
/// animations snap to their final state instead of running.
Duration motionDuration(BuildContext context, int ms) {
  final reduce = context.read<SettingsController>().reduceMotion;
  return reduce ? Duration.zero : Duration(milliseconds: ms);
}

bool reduceMotionOf(BuildContext context) =>
    context.read<SettingsController>().reduceMotion;
