import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../timer/providers/timer_provider.dart';
import '../timer/ui/quick_start_screen.dart';
import '../timer/ui/timer_visualizer_screen.dart';
import '../presets/ui/preset_list_screen.dart';
import '../history/ui/history_screen.dart';
import '../settings/ui/settings_screen.dart';
import '../settings/providers/settings_provider.dart';

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
    final timerState = ref.watch(timerProvider);
    final focusColor = ref.watch(activeFocusColorProvider);
    final breakColor = ref.watch(activeBreakColorProvider);

    final showMiniPlayer =
        (timerState.isRunning || timerState.isPaused) && !timerState.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.webp',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Pace Amigo',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),

              // Mini Player Banner when timer is active in background
              if (showMiniPlayer)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildMiniPlayer(
                    context,
                    timerState,
                    timerState.currentPhase.isFocus ? focusColor : breakColor,
                  ),
                ),
            ],
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

  Widget _buildMiniPlayer(
      BuildContext context, dynamic timerState, Color activeColor) {
    return Material(
      color: activeColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      shadowColor: Colors.black45,
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
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      timerState.formattedRemainingTime,
                      style: GoogleFonts.inter(
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
    );
  }
}
