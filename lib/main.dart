import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/library_repository.dart';
import 'services/audio_player_handler.dart';
import 'state/library_controller.dart';
import 'state/playback_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.airplanemode.airplanemode.audio',
      androidNotificationChannelName: 'Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  final settings = await SettingsController.load();

  final library = LibraryController(LibraryRepository());
  final playback = PlaybackController(handler);

  // Wire MediaStore artwork into the lock-screen / notification.
  handler.artworkFileResolver = library.writeArtworkFile;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: playback),
      ],
      child: const AirplaneModeApp(),
    ),
  );

  // Kick off the first library scan (permission dialog may appear).
  library.load();
}
