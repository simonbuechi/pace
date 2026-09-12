import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/core/services/pwa_service.dart';

class PwaInstallBanner extends ConsumerWidget {
  const PwaInstallBanner({super.key});

  static void showInstallInstructions(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.install_mobile_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Install Pace Amigo',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Full-screen, offline-ready interval timer',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isIOS) ...[
                  _buildStep(
                    context,
                    number: '1',
                    icon: Icons.ios_share_rounded,
                    title: 'Tap the Share button',
                    description:
                        'Located in the bottom navigation bar of Safari.',
                  ),
                  const SizedBox(height: 14),
                  _buildStep(
                    context,
                    number: '2',
                    icon: Icons.add_box_outlined,
                    title: 'Select "Add to Home Screen"',
                    description:
                        'Scroll down the share sheet and tap the Add to Home Screen option.',
                  ),
                  const SizedBox(height: 14),
                  _buildStep(
                    context,
                    number: '3',
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Confirm by tapping "Add"',
                    description:
                        'Pace Amigo will appear on your home screen like a native app.',
                  ),
                ] else ...[
                  _buildStep(
                    context,
                    number: '1',
                    icon: Icons.download_rounded,
                    title: 'Use Browser Install Prompt',
                    description:
                        'Click the Install icon (⊕) in the browser address bar, or tap the button below.',
                  ),
                  const SizedBox(height: 14),
                  _buildStep(
                    context,
                    number: '2',
                    icon: Icons.more_vert_rounded,
                    title: 'Or Open Browser Menu',
                    description:
                        'Open the browser menu (⋮) and select "Install app" or "Add to Home screen".',
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStep(
    BuildContext context, {
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);

    if (!pwaState.shouldShowInstallPrompt) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 8,
      shadowColor: Colors.black54,
      color: isDark ? const Color(0xFF231F33) : const Color(0xFF1E1E28),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.install_mobile_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Install Pace Amigo for full-screen mode',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                if (pwaState.canPrompt) {
                  final accepted =
                      await ref.read(pwaProvider.notifier).promptInstall();
                  if (!accepted && context.mounted) {
                    showInstallInstructions(context);
                  }
                } else {
                  showInstallInstructions(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF529A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Install',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFFFF529A),
                ),
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white70),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              tooltip: 'Dismiss',
              onPressed: () {
                ref.read(pwaProvider.notifier).dismissBanner();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated install element placed directly in the desktop sidebar / navigation rail.
class SidebarInstallCard extends ConsumerWidget {
  final bool isExtended;

  const SidebarInstallCard({super.key, required this.isExtended});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);
    if (!pwaState.shouldShowInstallPrompt) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isExtended) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Tooltip(
          message: 'Install Pace Amigo',
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              if (pwaState.canPrompt) {
                final accepted =
                    await ref.read(pwaProvider.notifier).promptInstall();
                if (!accepted && context.mounted) {
                  PwaInstallBanner.showInstallInstructions(context);
                }
              } else {
                PwaInstallBanner.showInstallInstructions(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMagenta.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.install_mobile_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1A29)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.install_mobile_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Install App',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: 'Dismiss',
                onPressed: () {
                  ref.read(pwaProvider.notifier).dismissBanner();
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Full-screen & offline mode',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryMagenta,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (pwaState.canPrompt) {
                  final accepted =
                      await ref.read(pwaProvider.notifier).promptInstall();
                  if (!accepted && context.mounted) {
                    PwaInstallBanner.showInstallInstructions(context);
                  }
                } else {
                  PwaInstallBanner.showInstallInstructions(context);
                }
              },
              child: Text(
                'Install Now',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

