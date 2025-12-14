import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';

import 'package:offline_music_player/main.dart';
import 'package:offline_music_player/services/audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds', (WidgetTester tester) async {
    final handler = await AudioService.init(
      builder: () => AppAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'test.channel.audio',
        androidNotificationChannelName: 'Test Audio',
        androidNotificationOngoing: true,
      ),
    );

    await tester.pumpWidget(MyApp(handler: handler));
    await tester.pump(); // build 1 frame

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
