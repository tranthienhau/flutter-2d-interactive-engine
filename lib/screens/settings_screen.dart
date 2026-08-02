import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/audio_controller.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Parent settings - the 3 audio channels + app options. Matches
/// design/08-settings-audio.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _bgm = true;
  bool _reduceMotion = false;
  bool _parentLock = true;

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioProvider);
    final store = ref.watch(localStoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppText.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3-Channel Audio', style: AppText.title),
                const SizedBox(height: 4),
                Text('Music, voice and effects mix independently.',
                    style: AppText.caption),
                const SizedBox(height: 12),
                for (final ch in AudioChannel.values)
                  _ChannelSlider(
                    channel: ch,
                    state: audio.state(ch),
                    onVolume: (v) {
                      audio.setVolume(ch, v);
                      store.setAudioLevel(ch.key, v);
                    },
                    onMute: (m) => audio.setMuted(ch, m),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.music_note_rounded,
                  label: 'Background Music',
                  value: _bgm,
                  onChanged: (v) {
                    setState(() => _bgm = v);
                    if (v) {
                      audio.playBgm('theme');
                    } else {
                      audio.stopAll();
                    }
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                _ToggleRow(
                  icon: Icons.motion_photos_off_rounded,
                  label: 'Reduce Motion',
                  value: _reduceMotion,
                  onChanged: (v) => setState(() => _reduceMotion = v),
                ),
                const Divider(height: 1, color: AppColors.border),
                _ToggleRow(
                  icon: Icons.lock_rounded,
                  label: 'Parent Lock',
                  value: _parentLock,
                  onChanged: (v) => setState(() => _parentLock = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt_rounded,
                  color: AppColors.danger),
              title: Text('Reset Progress',
                  style: AppText.body.copyWith(color: AppColors.danger)),
              onTap: () => _confirmReset(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
            'This clears all lesson stars and costume unlocks. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(progressProvider.notifier).reset();
              Navigator.pop(dctx);
            },
            child: const Text('Reset',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.channel,
    required this.state,
    required this.onVolume,
    required this.onMute,
  });

  final AudioChannel channel;
  final ChannelState state;
  final ValueChanged<double> onVolume;
  final ValueChanged<bool> onMute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => onMute(!state.muted),
          icon: Icon(
            state.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: state.muted ? AppColors.textTertiary : AppColors.accent,
          ),
        ),
        SizedBox(
          width: 92,
          child: Text(channel.label, style: AppText.label),
        ),
        Expanded(
          child: Slider(
            value: state.volume,
            onChanged: state.muted ? null : onVolume,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.accentTint,
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.accent),
      title: Text(label, style: AppText.body),
      value: value,
      activeThumbColor: AppColors.accent,
      onChanged: onChanged,
    );
  }
}
