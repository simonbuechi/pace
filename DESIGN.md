# Pace Amigo — Design System & Guidelines

> **"Clean and simple, yet unmistakably playful."**

Pace Amigo balances razor-sharp utility with tactile joy. The interface stays clean and uncluttered so users can focus on their rhythms and intervals without cognitive friction—while expressive micro-interactions, spring physics, and vibrant gradient accents infuse the product with warmth, energy, and charm.

---

## 1. Design Principles

### 1. Simple at Rest, Playful in Motion
- **Clarity First**: Screens are airy, uncluttered, and readable at a glance. Text is crisp, layouts have generous white space, and visual noise is eliminated.
- **Joyful Feedback**: When the user touches something, it responds with springy feedback, gentle bounces, and fluid morphs. The app feels alive, not mechanical.

### 2. Tactile & Organic
- Avoid rigid, harsh edges. Corners are generously rounded, buttons feel like physical rubber pills or polished stones, and interactions carry a sense of momentum and inertia.

### 3. Purposeful Vibrancy
- The signature gradient is the hero of the interface. We don't overwhelm every surface with saturated hues; instead, vibrant gradients emerge precisely where excitement, progress, and achievement happen.

---

## 2. Color System

### Primary Hero Gradient
The heartbeat of Pace Amigo is the vibrant diagonal transition between royal amethyst purple and electric rose magenta.

| Token | Hex Code | Color Role | Visual Character |
| :--- | :--- | :--- | :--- |
| **Gradient Start (Purple)** | `#9025A7` | Primary Accent / Anchor | Deep vibrant amethyst; conveys focus & momentum |
| **Gradient End (Magenta)** | `#D81860` | Primary Accent / Flash | Electric warm magenta; conveys energy & passion |

```dart
// Flutter Gradient Definition
static const LinearGradient primaryGradient = LinearGradient(
  colors: [
    Color(0xFF9025A7),
    Color(0xFFD81860),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

#### Gradient Glow & Shadow
For interactive elements (e.g. primary Start button or active timer thumb):
- **Box Shadow**: `Color(0xFFD81860).withOpacity(0.35)` with `blurRadius: 18`, `offset: Offset(0, 8)`.

---

### Supporting & Semantic Palettes

#### Light Theme
- **Scaffold Background**: `#F8F9FD` (Clean, subtle cool porcelain)
- **Surface / Card**: `#FFFFFF` (Pure white)
- **Card Outline**: `rgba(144, 37, 167, 0.08)` (Subtle tinted border)
- **Text High-Contrast**: `#1E1622` (Deep plum charcoal)
- **Text Muted / Subtitle**: `#6D6775` (Warm slate)
- **Break / Rest Phase**: `#D81860` (Primary Electric Magenta)

#### Dark Theme
- **Scaffold Background**: `#100E17` (Deep obsidian plum)
- **Surface / Card**: `#1C1826` (Midnight amethyst card)
- **Card Outline**: `rgba(216, 24, 96, 0.12)` (Electric faint edge)
- **Text High-Contrast**: `#FDFDFE` (Soft bright white)
- **Text Muted / Subtitle**: `#A59DB1` (Muted lilac grey)
- **Break / Rest Phase**: `#D81860` (Primary Electric Magenta)

> **Pure Color System**: The app uses primary colors exclusively (`#9025A7` for Focus and `#D81860` for Break / Rest) without external palette options, ensuring absolute brand consistency and clarity.

---

## 3. Typography

Pace Amigo utilizes **Inter** (Google Fonts) for clean, neutral, highly objective, and readable modern typography across all platforms.

```dart
TextTheme get appTextTheme => GoogleFonts.interTextTheme();
```

### Type Scale

| Role | Style / Weight | Size | Usage |
| :--- | :--- | :--- | :--- |
| **Display Timer** | ExtraBold (800) | `56px` - `72px` | Large active countdown numbers |
| **Heading 1** | Bold (700) | `26px` - `30px` | Main screen titles & sheet headers |
| **Heading 2** | SemiBold (600) | `18px` - `22px` | Card section titles, routine names |
| **Body Large** | Medium (500) | `15px` - `16px` | Interactive labels, list item descriptions |
| **Caption / Badge** | SemiBold (600) | `11px` - `12px` | Phase badges, micro metadata (UPPERCASE, letter-spacing +1.0) |

---

## 4. Geometry & Elevation

- **Buttons & Chips**: Pill or squircle (`BorderRadius.circular(16)` to `BorderRadius.circular(999)`).
- **Cards & Modals**: Soft curved corners (`BorderRadius.circular(24)`).
- **Floating Controls**: High elevation (`elevation: 6-10`) with tinted gradient drop-shadows.
- **Outlines**: `1.0px` to `1.5px` border thickness with slight transparency to preserve softness.

---

## 5. Animation & Motion Guidelines

Motion is where Pace Amigo's playfulness truly shines. Every movement should feel springy, responsive, and delightful rather than clinical.

### Motion Principles
1. **Spring over Linear**: Never use raw linear curves for UI elements. Use bouncy, organic curves such as `Curves.easeOutBack` or spring simulations.
2. **Squash and Stretch**: Tapping an item briefly compresses it before it fires or bounces back.
3. **Breathing Rhythm**: Passive screens have subtle, alive pulsations (e.g. ambient timer glow during focus).

### Standard Curves & Durations

| Animation Role | Duration | Curve | Flutter Example |
| :--- | :--- | :--- | :--- |
| **Tap / Press Feedback** | `100ms - 150ms` | `Curves.easeInOut` | Scale from `1.0` down to `0.94` |
| **Release / Bounce Back** | `250ms - 350ms` | `Curves.easeOutBack` | Overshoots to `1.02` then rests at `1.0` |
| **Card Flip / Screen Entry** | `300ms - 450ms` | `Curves.fastOutSlowIn` | Slide up + fade in |
| **Breathing Glow** | `2400ms` loop | `Curves.easeInOutSine` | Opacity pulses between `0.2` and `0.5` |
| **Session Finished Pop** | `600ms` | `Curves.elasticOut` | Celebration badge scales from `0.0` to `1.15` to `1.0` |

### Playful Animation Catalog

#### A. Tactile "Bouncy" Button (`ScaleOnPress`)
When buttons or preset cards are tapped, they scale down slightly and pop back up with elastic momentum:
```dart
class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BouncyButton({super.key, required this.child, required this.onTap});

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 250),
    lowerBound: 0.0,
    upperBound: 0.06, // 6% press down
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: 1.0 - _controller.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
```

#### B. The Pulsing Gradient Progress Ring
- As the timer counts down, the circular sweep has smooth rounded caps.
- At the tip of the sweep, a tiny glowing orb pulses rhythmically (`scale: 1.0 -> 1.25 -> 1.0`).
- A subtle radial gradient halo behind the ring expands and contracts in sync with human breathing (approx 4 seconds per cycle).

#### C. Confetti / Stamp of Completion
- Upon completing a focus or workout session:
  - An animated confetti burst of purple and magenta dots spreads outward.
  - A celebratory checkmark or trophy badge drops in with `Curves.elasticOut`.
  - Haptic feedback triggers (light double-impact).

---

## 6. Key Component Showcase

### 1. Primary Action Button (Start / Resume)
- **Background**: Diagonal gradient `#9025A7` &rarr; `#D81860`.
- **Text**: White, `16px`, `FontWeight.w700`.
- **Icon**: Bold rounded icon (`Icons.play_arrow_rounded` or `Icons.pause_rounded`).
- **Shadow**: `BoxShadow(color: Color(0xFFD81860).withOpacity(0.35), blurRadius: 16, offset: Offset(0, 6))`.
- **Corner Radius**: Fully rounded pill (`borderRadius: BorderRadius.circular(999)`).

### 2. Timer Dial Card
- White/Dark card with a light background gradient sheen.
- Clear, ultra-bold numbers (`72px`) centered inside the dial.
- Interactive scrub handles with playful spring snaps when adjusted.

### 3. Mini-Player Banner
- Floats above the bottom navigation bar with a rounded pill silhouette (`BorderRadius.circular(24)`).
- Dressed in the gradient when active, providing high visual hierarchy without blocking the screen.

### 4. Brand Mark & Logo
- **Asset**: `assets/logo.webp` (1000x1000 master asset)
- **Design**: Stopwatch outline with quadrant focus indicator filled with white over the signature `#9025A7` to `#D81860` gradient background.
- **Application**:
  - **In-App Navigation**: Embedded at `28x28px` with `8px` border radius in the top `AppBar`.
  - **About / Settings**: Displayed at `64x64px` with `20px` border radius and soft ambient magenta shadow.
  - **App Icons & Favicon**: Synchronized across Android mipmaps (`ic_launcher.png`), iOS AppIcon set (`20px`–`1024px`), Web favicon (`web/favicon.png`), Web PWA icons (`192px`, `512px`, maskable), and Windows (`app_icon.ico`).

---

## 7. Do's and Don'ts

| Do | Don't |
| :--- | :--- |
| **Do** keep layouts clean with generous negative space. | **Don't** clutter screens with dense lists or tiny text. |
| **Do** use the `#9025A7` &rarr; `#D81860` gradient on key focus elements. | **Don't** paint entire page backgrounds with raw saturated gradient. |
| **Do** give buttons and cards bouncy, spring-based tap feedback. | **Don't** use slow, sluggish, or robotic linear transitions. |
| **Do** use rounded pill buttons and soft squircles. | **Don't** use sharp 90-degree corners or harsh rectangular boxes. |
| **Do** celebrate finished timers with rewarding micro-animations. | **Don't** just abruptly stop the timer without visual delight. |
