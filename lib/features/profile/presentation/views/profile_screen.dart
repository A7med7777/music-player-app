import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:music_player_app/features/profile/presentation/viewmodels/settings_viewmodel.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Consumer2<ProfileViewModel, SettingsViewModel>(
        builder: (context, profileVm, settingsVm, _) {
          if (profileVm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileVm.failure != null) {
            return const ErrorState(message: 'Could not load profile');
          }
          final profile = profileVm.profile;
          final settings = settingsVm.settings;
          final summary = profileVm.summary;

          return ListView(
            children: [
              // Avatar + display name
              Padding(
                padding: EdgeInsets.all(tokens.spacing24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    SizedBox(height: tokens.spacing12),
                    _EditableDisplayName(
                      name: profile?.displayName ?? '',
                      onSave: profileVm.updateName,
                    ),
                    if (summary != null) ...[
                      SizedBox(height: tokens.spacing16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SummaryChip(
                            label: 'Songs',
                            count: summary.totalTracks,
                            tokens: tokens,
                          ),
                          _SummaryChip(
                            label: 'Liked',
                            count: summary.totalLiked,
                            tokens: tokens,
                          ),
                          _SummaryChip(
                            label: 'Playlists',
                            count: summary.totalPlaylists,
                            tokens: tokens,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(),

              // Appearance
              _SectionTitle('Appearance', tokens: tokens),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  onChanged: (v) => settingsVm.setTheme(v!),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Audio
              _SectionTitle('Audio', tokens: tokens),
              ListTile(
                title: const Text('Audio quality'),
                trailing: DropdownButton<AudioQuality>(
                  value: settings.audioQuality,
                  underline: const SizedBox.shrink(),
                  onChanged: (v) => settingsVm.setAudioQuality(v!),
                  items: const [
                    DropdownMenuItem(
                      value: AudioQuality.auto,
                      child: Text('Auto'),
                    ),
                    DropdownMenuItem(
                      value: AudioQuality.low,
                      child: Text('Low'),
                    ),
                    DropdownMenuItem(
                      value: AudioQuality.normal,
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: AudioQuality.high,
                      child: Text('High'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.spacing16,
                  0,
                  tokens.spacing16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crossfade: ${(settings.crossfadeMs / 1000).toStringAsFixed(1)} s',
                    ),
                    Slider(
                      value: settings.crossfadeMs.toDouble(),
                      min: 0,
                      max: 12000,
                      divisions: 24,
                      label:
                          '${(settings.crossfadeMs / 1000).toStringAsFixed(1)} s',
                      onChanged: (v) =>
                          settingsVm.setCrossfade(v.round()),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Show explicit content'),
                trailing: Switch(
                  value: settings.showExplicit,
                  onChanged: settingsVm.setShowExplicit,
                ),
              ),
              const Divider(),

              // Data & Integrations
              _SectionTitle('Integrations', tokens: tokens),
              ListTile(
                title: const Text('Cloud sync'),
                trailing: Switch(
                  value: settings.cloudSyncEnabled,
                  onChanged: settingsVm.setCloudSyncEnabled,
                ),
              ),
              ListTile(
                title: const Text('Spotify'),
                subtitle: Text(
                  settings.spotifyEnabled ? 'Connected' : 'Not connected',
                ),
                trailing: Switch(
                  value: settings.spotifyEnabled,
                  onChanged: settingsVm.setSpotifyEnabled,
                ),
              ),
              SizedBox(height: tokens.spacing32),
            ],
          );
        },
      ),
    );
  }
}

class _EditableDisplayName extends StatefulWidget {
  const _EditableDisplayName({required this.name, required this.onSave});
  final String name;
  final Future<void> Function(String) onSave;

  @override
  State<_EditableDisplayName> createState() => _EditableDisplayNameState();
}

class _EditableDisplayNameState extends State<_EditableDisplayName> {
  bool _editing = false;
  late final _controller = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await widget.onSave(_controller.text.trim());
              if (mounted) setState(() => _editing = false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _editing = false),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.name.isEmpty ? 'Tap to set name' : widget.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit, size: 18),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.tokens,
  });
  final String label;
  final int count;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.tokens});
  final String title;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing16,
        tokens.spacing16,
        tokens.spacing16,
        tokens.spacing4,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
