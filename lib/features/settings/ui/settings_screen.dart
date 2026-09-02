import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/core/constants/app_sounds.dart';
import 'package:pace_amigo/core/providers/core_providers.dart';
import 'package:pace_amigo/core/services/sync_service.dart';
import 'package:pace_amigo/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final syncService = ref.watch(cloudSyncServiceProvider);
    final audio = ref.read(audioServiceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tailor appearance, transition audio, and cloud sync.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Cloud Sync & Account Section
                _buildSyncCard(context, ref, syncService),

                const SizedBox(height: 24),


                // 2. Appearance (Light / Dark Mode)
                Text(
                  'Appearance',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_rounded),
                              label: Text('System'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded),
                              label: Text('Light'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded),
                              label: Text('Dark'),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (val) {
                            settingsNotifier.setThemeMode(val.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Alert Sounds
                Text(
                  'Transition Alert Sounds',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose distinct audio cues for entering Focus and Break sessions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.volume_up_rounded),
                          title: Text('Sound Alerts',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          subtitle: const Text('Play sound on interval transitions'),
                          value: settings.soundEnabled,
                          onChanged: (val) =>
                              settingsNotifier.toggleSound(val),
                        ),
                        const Divider(),
                        // Focus Sound selector
                        _buildSoundSelector(
                          context,
                          title: 'Focus Start Sound',
                          subtitle: 'Cues the start of a focus interval',
                          selectedSoundId: settings.focusSoundId,
                          onChanged: (id) => settingsNotifier.setFocusSound(id),
                          onPreview: (sound) => audio.playSound(sound),
                        ),
                        const Divider(),
                        // Break Sound selector
                        _buildSoundSelector(
                          context,
                          title: 'Break Start Sound',
                          subtitle: 'Cues the start of a rest interval',
                          selectedSoundId: settings.breakSoundId,
                          onChanged: (id) => settingsNotifier.setBreakSound(id),
                          onPreview: (sound) => audio.playSound(sound),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. System Notifications
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_rounded),
                    title: Text('Background Notifications',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                      'Alert when intervals finish even if the app runs in the background',
                    ),
                    value: settings.notificationsEnabled,
                    onChanged: (val) {
                      settingsNotifier.toggleNotifications(val);
                      if (val) {
                        ref
                            .read(notificationServiceProvider)
                            .requestPermissions();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD81860).withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/logo.webp',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pace Amigo',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0 • Clean, Simple & Playful',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncCard(
      BuildContext context, WidgetRef ref, CloudSyncService syncService) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<SyncUser?>(
      valueListenable: syncService.currentUser,
      builder: (context, user, _) {
        final isLoggedIn = user != null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isLoggedIn
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          child: Icon(
                            isLoggedIn
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            color: isLoggedIn ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoggedIn ? 'Cloud Sync Active' : 'Offline-First Mode',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              isLoggedIn
                                  ? (user.email ??
                                      (syncService.isFirebaseConfigured
                                          ? 'Synced to Firebase (${syncService.firebaseProjectId})'
                                          : 'Synced to Cloud'))
                                  : (syncService.isFirebaseConfigured
                                      ? 'Backend: Firebase (${syncService.firebaseProjectId})'
                                      : 'Data stored locally on this device'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isLoggedIn
                      ? 'Your routines, presets, and preferences are safely synchronized with Firebase.'
                      : 'You can use Pace Amigo completely offline. Connect your Google Account anytime to sync across devices.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: isLoggedIn
                      ? OutlinedButton.icon(
                          onPressed: () => syncService.signOut(),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Disconnect Account'),
                        )
                      : FilledButton.icon(
                          onPressed: () => syncService.signInWithGoogle(),
                          icon: const Icon(Icons.account_circle_rounded),
                          label: const Text('Sign in with Google Account'),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundSelector(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String selectedSoundId,
    required void Function(String) onChanged,
    required void Function(SoundOption) onPreview,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...AppSounds.all.map((sound) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: sound.id,
            groupValue: selectedSoundId,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            title: Text(sound.name,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(sound.description,
                style: GoogleFonts.inter(fontSize: 12)),
            secondary: IconButton(
              icon: const Icon(Icons.play_circle_outline_rounded),
              tooltip: 'Preview sound',
              onPressed: () => onPreview(sound),
            ),
          );
        }),
      ],
    );
  }
}
