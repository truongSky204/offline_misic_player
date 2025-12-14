import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Volume', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
            child: Slider(
              value: provider.volume,
              min: 0.0,
              max: 1.0,
              onChanged: (v) => provider.setVolume(v),
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Note: Playback continues in background (audio_service).',
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}
