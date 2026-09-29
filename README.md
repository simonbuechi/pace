# Pace Amigo

**Pace Amigo** (or **Pace** for short) is a clean, modern, and highly customizable interval timer web application built with **React 18**, **TypeScript**, **Vite**, **Tailwind CSS**, and the **Web Audio API**.

Live Web App: **[pace.simibu.ch](https://pace.simibu.ch/)**

---

## ✨ Features

* **Direct Numeric Quick Start**: Enter precise **Minutes** and **Seconds** for Focus and Break intervals (`[ MM ] min : [ SS ] sec`), plus custom **Round Iterations** (`[ NN ] rounds`) with clean steppers and synchronized sliders.
* **Routine Library & Sequence Studio**: Create, edit, duplicate, and organize custom interval routines with arbitrary multi-phase sequences (e.g. Warmup, High Intensity, Rest, Cooldown).
* **Routine Completion Logging**: Sessions that run to completion without early cancellation are automatically logged to browser storage with full telemetry (total time, cycles, focus/break breakdown, and timestamp). View logs directly on routine cards.
* **Material 3 Expressive Styling**: Calmed, uncluttered visual aesthetic with subtle micro-borders, airy spacing, and a signature primary action gradient from `#9123A6` to `#D7195F`.
* **Single Sans-Serif Typography**: Clean, unified type hierarchy using `Plus Jakarta Sans` throughout the app. Numeric readouts use `tabular-nums` for alignment without monospace fonts.
* **Immersive Fullscreen Visualizer**: Distraction-free focus mode with smooth atmospheric color breathing matching the active interval phase.
* **Real-Time Web Audio Synthesizer**: Pure procedural 24-bit zero-latency alerts generated via the Web Audio API (*Standard Beep*, *Temple Bell*, *Digital Pulse*) with zero external audio assets.
* **Light & Dark Theme Engine**: Instant theme switching (*Light*, *Dark*, *System OS*) with curated Material 3 color palettes and custom hex color overrides.
* **Wall-Clock Drift Compensation**: Countdown engine compensates for background tab throttling using high-precision timestamp deltas.
* **Desktop Notifications**: Background tab interval alerts powered by the browser Notification API.
* **Floating Mini-Player**: Live countdown pill persists while configuring routines or settings during an active session.
* **Keyboard Shortcuts**:
  * `Space`: Play / Pause timer
  * `N` / `→`: Skip to Next interval
  * `P` / `←`: Skip to Previous interval
  * `R`: Reset routine
  * `F`: Toggle Fullscreen visualizer
  * `M`: Mute / Unmute alert sounds
  * `Esc`: Minimize visualizer
  * `1`, `2`, `3`: Switch views (*Quick Start*, *Routines*, *Settings*)

---

## 🏗️ Architecture & Tech Stack

* **Framework**: [React 18](https://react.dev/) + [TypeScript](https://www.typescriptlang.org/)
* **Build Tool**: [Vite 8](https://vitejs.dev/)
* **Styling**: [Tailwind CSS 3](https://tailwindcss.com/)
* **Icons**: [Lucide React](https://lucide.dev/)
* **Audio**: Native [Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API) procedural synthesis
* **Testing**: [Vitest](https://vitest.dev/)
* **Linter**: [Oxlint](https://oxc.rs/)
* **Deployment**: GitHub Pages via GitHub Actions with custom domain (`pace.simibu.ch`)

---

## 🛠️ Development & Build

### Prerequisites
* [Node.js](https://nodejs.org/) (v20 or higher recommended)
* `npm`

### Commands

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run unit tests
npm test

# Run linter
npm run lint

# Build production bundle (tsc -b && vite build)
npm run build

# Preview production build locally
npm run preview
```

---

## 🚀 Deployment (GitHub Pages)

The repository includes an automated GitHub Actions deployment workflow at [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml):

1. Triggers automatically on push to the `main` branch (or via manual `workflow_dispatch`).
2. Installs dependencies via `npm ci`.
3. Runs the test suite via `npm test`.
4. Compiles the production bundle via `npm run build` into `dist/`.
5. Includes `public/CNAME` (`pace.simibu.ch`) in the build output.
6. Deploys to GitHub Pages at **`https://pace.simibu.ch/`**.
