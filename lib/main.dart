import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/audio_handler.dart';
import 'package:harmonymusic/ui/home.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/song.dart';
import 'ui/screens/home_screen_controller.dart';
import 'ui/utils/home_library_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  Get.put<AudioHandler>(await initAudioService(), permanent: true);
  startApplicationServices();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: true),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.resumed") {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarContrastEnforced: true),
        );
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
    return GetX<ThemeController>(builder: (controller) {
      return GetMaterialApp(
        title: 'Harmony Music',
        theme: controller.themedata.value,
        home: const Home(),
      );
    });
  }
}

Future<void> startApplicationServices() async {
  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => PlayerController(), fenix: true);
  Get.lazyPut(() => HomeScreenController());
  Get.lazyPut(() => HomeLibrayController(),fenix: true);
}

initHive() async {
  Directory applicationDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(applicationDirectory.path);
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox("SongsCache");
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox("settings");
}