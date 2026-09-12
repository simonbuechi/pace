import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/core/constants/app_sounds.dart';
import 'package:pace_amigo/core/providers/core_providers.dart';
import 'package:pace_amigo/core/services/pwa_service.dart';
import 'package:pace_amigo/core/services/sync_service.dart';
import 'package:pace_amigo/features/home/widgets/pwa_install_banner.dart';
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


                // 2. Appearance (System / Light / Dark Mode)
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _buildThemeSegment(
                                theme: theme,
                                label: 'System',
                                icon: Icons.brightness_auto_rounded,
                                isSelected:
                                    settings.themeMode == ThemeMode.system,
                                onTap: () => settingsNotifier
                                    .setThemeMode(ThemeMode.system),
                              ),
                              _buildThemeSegment(
                                theme: theme,
                                label: 'Light',
                                icon: Icons.light_mode_rounded,
                                isSelected:
                                    settings.themeMode == ThemeMode.light,
                                onTap: () => settingsNotifier
                                    .setThemeMode(ThemeMode.light),
                              ),
                              _buildThemeSegment(
                                theme: theme,
                                label: 'Dark',
                                icon: Icons.dark_mode_rounded,
                                isSelected:
                                    settings.themeMode == ThemeMode.dark,
                                onTap: () => settingsNotifier
                                    .setThemeMode(ThemeMode.dark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          secondary: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primaryPurple,
                                size: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            'Background Animations',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text(
                            'Dynamic ambient atmosphere & floating energy orbs in visualizer',
                          ),
                          value: settings.backgroundAnimationsEnabled,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            settingsNotifier.toggleBackgroundAnimations(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 24),

                // 3. Default Sounds (Separate Focus and Break sound cards)
                Text(
                  'Default Sounds',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Configure distinct default audio cues for focus intervals and rest breaks.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Master sound toggle card
                Card(
                  child: SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Sound Alerts',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    subtitle:
                        const Text('Play audio cues on interval transitions'),
                    value: settings.soundEnabled,
                    onChanged: (val) => settingsNotifier.toggleSound(val),
                  ),
                ),

                const SizedBox(height: 16),

                // Dedicated Separate Focus Sound Card
                _buildSeparateSoundCard(
                  context,
                  theme: theme,
                  title: 'Focus Start Sound',
                  subtitle: 'Plays when entering a focus session',
                  icon: Icons.bolt_rounded,
                  accentColor: AppColors.primaryPurple,
                  selectedSoundId: settings.focusSoundId,
                  isEnabled: settings.soundEnabled,
                  onChanged: (id) => settingsNotifier.setFocusSound(id),
                  onPreview: (sound) => audio.playSound(sound),
                ),

                const SizedBox(height: 16),

                // Dedicated Separate Break Sound Card
                _buildSeparateSoundCard(
                  context,
                  theme: theme,
                  title: 'Break Start Sound',
                  subtitle: 'Plays when entering a rest break',
                  icon: Icons.spa_rounded,
                  accentColor: AppColors.primaryMagenta,
                  selectedSoundId: settings.breakSoundId,
                  isEnabled: settings.soundEnabled,
                  onChanged: (id) => settingsNotifier.setBreakSound(id),
                  onPreview: (sound) => audio.playSound(sound),
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

                if (kIsWeb) ...[
                  const SizedBox(height: 24),
                  Text(
                    'App Installation',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPwaCard(context, ref),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPwaCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pwaState = ref.watch(pwaProvider);
    final isInstalled = pwaState.isStandalone;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isInstalled
                      ? Colors.green.withValues(alpha: 0.15)
                      : AppColors.primaryPurple.withValues(alpha: 0.15),
                  child: Icon(
                    isInstalled
                        ? Icons.check_circle_rounded
                        : Icons.install_mobile_rounded,
                    color: isInstalled ? Colors.green : AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInstalled ? 'Installed as App' : 'Browser Mode (Installable)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        isInstalled
                            ? 'Running standalone outside the browser.'
                            : 'Install on your device for distraction-free full screen.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isInstalled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    if (pwaState.canPrompt) {
                      ref.read(pwaProvider.notifier).promptInstall();
                    } else {
                      PwaInstallBanner.showInstallInstructions(context);
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Install Pace Amigo'),
                ),
              ),
            ],
          ],
        ),
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

  Widget _buildThemeSegment({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF282338) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primaryPurple
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparateSoundCard(
    BuildContext context, {
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String selectedSoundId,
    required bool isEnabled,
    required void Function(String) onChanged,
    required void Function(SoundOption) onPreview,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Sound Options List
            ...AppSounds.all.map((sound) {
              final isSelected = sound.id == selectedSoundId;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isEnabled
                      ? () {
                          HapticFeedback.selectionClick();
                          onChanged(sound.id);
                        }
                      : null,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        // Radio indicator
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? accentColor
                              : theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sound.name,
                                style: GoogleFonts.inter(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13.5,
                                  color: isEnabled
                                      ? (isSelected
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant)
                                      : theme.disabledColor,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                sound.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11.5,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Preview play button
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: accentColor.withValues(
                                alpha: isSelected ? 0.15 : 0.06),
                            foregroundColor: accentColor,
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(34, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          tooltip: 'Preview sound',
                          onPressed: isEnabled ? () => onPreview(sound) : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
