import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';

import 'services/audio_handler.dart';
import 'services/storage_service.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: () => AppAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.offline_music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(MyApp(handler: handler));
}

class MyApp extends StatelessWidget {
  final AppAudioHandler handler;
  const MyApp({super.key, required this.handler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: handler),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(
          create: (ctx) => AudioProvider(
            audioHandler: ctx.read<AppAudioHandler>(),
            storage: ctx.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PlaylistProvider(storage: ctx.read<StorageService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline Music Player',
        theme: ThemeData.dark(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
