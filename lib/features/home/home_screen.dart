import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../timer/providers/timer_provider.dart';
import '../timer/ui/quick_start_screen.dart';
import '../timer/ui/timer_visualizer_screen.dart';
import '../presets/ui/preset_list_screen.dart';
import '../history/ui/history_screen.dart';
import '../../core/services/pwa_service.dart';
import '../settings/ui/settings_screen.dart';
import 'widgets/pwa_install_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    QuickStartScreen(),
    PresetListScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTimerActive = ref.watch(
      timerProvider.select(
        (s) => (s.isRunning || s.isPaused) && !s.isCompleted,
      ),
    );
    final showMiniPlayer = isTimerActive && _currentIndex != 0;
    final pwaState = ref.watch(pwaProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 768;
    final isExtendedRail = screenWidth >= 1024;

    final contentArea = Stack(
      children: [
        IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),

        // Mini Player Banner when timer is active in background
        if (showMiniPlayer)
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: RepaintBoundary(
              child: HomeMiniPlayer(),
            ),
          ),

        // Floating PWA Install SnackBar at bottom (mobile only)
        if (pwaState.shouldShowInstallPrompt && !isDesktop)
          Positioned(
            right: 16,
            left: 16,
            bottom: showMiniPlayer ? 96 : 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: const PwaInstallBanner(),
              ),
            ),
          ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left Navigation Rail for desktop / tablet
            NavigationRail(
              selectedIndex: _currentIndex,
              extended: isExtendedRail,
              minExtendedWidth: 210,
              backgroundColor: theme.colorScheme.surface,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              leading: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: isExtendedRail
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/logo.webp',
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pace Amigo',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/logo.webp',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pace Amigo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
              ),
              trailing: pwaState.shouldShowInstallPrompt
                  ? Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SidebarInstallCard(isExtended: isExtendedRail),
                      ),
                    )
                  : null,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt_rounded),
                  label: Text('Quick Start'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.view_agenda_outlined),
                  selectedIcon: Icon(Icons.view_agenda_rounded),
                  label: Text('Routines'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: contentArea,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout (< 768px)
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: contentArea,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt_rounded),
            label: 'Quick Start',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_agenda_outlined),
            selectedIcon: Icon(Icons.view_agenda_rounded),
            label: 'Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeMiniPlayer extends ConsumerWidget {
  const HomeMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final Gradient activeGradient = timerState.currentPhase.isFocus
        ? AppColors.primaryGradient
        : AppColors.silverGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: activeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TimerVisualizerScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Icon(
                  timerState.currentPhase.isFocus
                      ? Icons.flash_on_rounded
                      : Icons.spa_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timerState.currentPhase.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        timerState.formattedRemainingTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    timerState.isRunning
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    final notifier = ref.read(timerProvider.notifier);
                    if (timerState.isRunning) {
                      notifier.pause();
                    } else {
                      notifier.start();
                    }
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TimerVisualizerScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
