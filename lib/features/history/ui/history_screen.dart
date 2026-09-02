import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pace_amigo/core/config/firebase_config.dart';
import 'package:pace_amigo/core/constants/app_colors.dart';
import 'package:pace_amigo/features/history/models/focus_run_log.dart';
import 'package:pace_amigo/features/history/providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day - 1;

    final hourStr = dt.hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minuteStr';

    if (isToday) return 'Today at $timeStr';
    if (isYesterday) return 'Yesterday at $timeStr';
    return '${dt.day}/${dt.month}/${dt.year} at $timeStr';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyLogs = ref.watch(historyProvider);
    final totalFocusMinutes = ref.watch(totalFocusMinutesProvider);
    final todayRuns = ref.watch(todayRunsCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'History',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (historyLogs.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Sync with Firebase',
                          onPressed: () {
                            ref.read(historyProvider.notifier).syncAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Syncing runs with Firebase...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and celebrate all your finished focus runs.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Total Focus',
                          value: '${totalFocusMinutes}m',
                          icon: Icons.timer_rounded,
                          accentColor: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Completed Runs',
                          value: '${historyLogs.length}',
                          icon: Icons.check_circle_rounded,
                          accentColor: AppColors.primaryMagenta,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Today',
                          value: '$todayRuns',
                          icon: Icons.bolt_rounded,
                          accentColor: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cloud Sync Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: FirebaseConfig.isConfigured
                          ? Colors.green.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FirebaseConfig.isConfigured
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FirebaseConfig.isConfigured
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          size: 16,
                          color: FirebaseConfig.isConfigured
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FirebaseConfig.isConfigured
                              ? 'Cloud Sync: Connected to Firebase (${FirebaseConfig.projectId})'
                              : 'Offline Mode: Stored locally in Hive',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FirebaseConfig.isConfigured
                                ? Colors.green.shade800
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Run List or Empty State
          if (historyLogs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryPurple.withValues(alpha: 0.2),
                              AppColors.primaryMagenta.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.history_toggle_off_rounded,
                          size: 40,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Completed Runs Yet',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When you finish a focus interval or full routine, it will automatically appear here and sync to Firebase. Cancelled runs are never logged.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = historyLogs[index];
                    return _buildRunCard(context, ref, log);
                  },
                  childCount: historyLogs.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunCard(
    BuildContext context,
    WidgetRef ref,
    FocusRunLog log,
  ) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(historyProvider.notifier).deleteLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${log.presetName} run log'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gradient check avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title and completion time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.presetName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDateTime(log.completedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Cloud sync indicator
                        Tooltip(
                          message: log.isSynced
                              ? 'Synced to Firebase'
                              : 'Pending cloud sync',
                          child: Icon(
                            log.isSynced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_upload_outlined,
                            size: 14,
                            color: log.isSynced
                                ? Colors.green
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Duration & Cycles Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      log.formattedDuration,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log.iterations} ${log.iterations == 1 ? 'cycle' : 'cycles'}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
