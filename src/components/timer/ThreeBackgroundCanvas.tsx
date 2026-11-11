import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';
import type { BackgroundAnimationId } from '../../types';

interface ThreeBackgroundCanvasProps {
  animation: BackgroundAnimationId;
  isRunning: boolean;
  baseColor: string;
}

// Helper to create a soft circular gradient texture for particles
const createSoftCircleTexture = (): THREE.CanvasTexture => {
  const canvas = document.createElement('canvas');
  canvas.width = 64;
  canvas.height = 64;
  const ctx = canvas.getContext('2d');
  if (ctx) {
    const gradient = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
    gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
    gradient.addColorStop(0.3, 'rgba(255, 255, 255, 0.7)');
    gradient.addColorStop(0.7, 'rgba(255, 255, 255, 0.2)');
    gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 64, 64);
  }
  const texture = new THREE.CanvasTexture(canvas);
  return texture;
};

// Generate harmonic, vibrant complementary and analog palette anchored on the baseColor
const derivePalette = (baseHex: string) => {
  const base = new THREE.Color(baseHex || '#d7195f');
  const hsl = { h: 0, s: 0, l: 0 };
  base.getHSL(hsl);

  // Analogous color 1 (+35 deg shift, high saturation)
  const analog1 = new THREE.Color().setHSL((hsl.h + 0.1) % 1, Math.min(1, hsl.s * 1.1 + 0.1), Math.max(0.45, hsl.l));
  // Analogous color 2 (-35 deg shift, deep warm/cool)
  const analog2 = new THREE.Color().setHSL((hsl.h + 0.9) % 1, Math.min(1, hsl.s * 1.05 + 0.1), Math.max(0.5, hsl.l));
  // Complementary accent (vibrant pop)
  const accent = new THREE.Color().setHSL((hsl.h + 0.5) % 1, 0.95, 0.62);
  // Soft pastel tint for highlights
  const tint = new THREE.Color().setHSL(hsl.h, 0.6, 0.85);

  return { base, analog1, analog2, accent, tint };
};

export const ThreeBackgroundCanvas: React.FC<ThreeBackgroundCanvasProps> = ({
  animation,
  isRunning,
  baseColor,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const animationFrameRef = useRef<number | null>(null);
  const isRunningRef = useRef(isRunning);
  const baseColorRef = useRef(baseColor);

  useEffect(() => {
    isRunningRef.current = isRunning;
  }, [isRunning]);

  useEffect(() => {
    baseColorRef.current = baseColor;
  }, [baseColor]);

  useEffect(() => {
    if (!containerRef.current || animation === 'none') {
      return;
    }

    const container = containerRef.current;
    const width = container.clientWidth || window.innerWidth;
    const height = container.clientHeight || window.innerHeight;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    camera.position.z = 24;

    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({
        alpha: true,
        antialias: true,
        powerPreference: 'high-performance',
      });
    } catch (e) {
      console.warn('WebGL not supported or context lost:', e);
      return;
    }

    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.innerHTML = '';
    container.appendChild(renderer.domElement);

    const softTexture = createSoftCircleTexture();
    let cleanupAnimation: () => void = () => {};

    // =========================================================================
    // 1. BREATHING PULSE (Fluid Luminous Halo Ripples & Chromatic Particle Bloom)
    // =========================================================================
    if (animation === 'breathing') {
      const group = new THREE.Group();
      const palette = derivePalette(baseColorRef.current);

      // Multiple soft flowing smooth concentric discs
      const discCount = 5;
      const discs: { mesh: THREE.Mesh; baseScale: number; speedOffset: number; mat: THREE.MeshBasicMaterial }[] = [];
      const discGeo = new THREE.RingGeometry(0.1, 8.5, 64);

      for (let i = 0; i < discCount; i++) {
        const color = i % 2 === 0 ? palette.base : i % 3 === 0 ? palette.analog1 : palette.analog2;
        const mat = new THREE.MeshBasicMaterial({
          color: color.clone(),
          transparent: true,
          opacity: 0.18 - i * 0.025,
          side: THREE.DoubleSide,
          blending: THREE.AdditiveBlending,
          depthWrite: false,
        });
        const mesh = new THREE.Mesh(discGeo, mat);
        mesh.position.z = -i * 1.5;
        group.add(mesh);
        discs.push({ mesh, baseScale: 1 + i * 0.45, speedOffset: i * 0.4, mat });
      }

      // Floating chromatic dust particles
      const pCount = 380;
      const pGeo = new THREE.BufferGeometry();
      const pPos = new Float32Array(pCount * 3);
      const pColors = new Float32Array(pCount * 3);

      for (let i = 0; i < pCount; i++) {
        const r = 4 + Math.random() * 22;
        const theta = Math.random() * Math.PI * 2;
        const phi = Math.acos(Math.random() * 2 - 1);
        pPos[i * 3] = r * Math.sin(phi) * Math.cos(theta);
        pPos[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
        pPos[i * 3 + 2] = r * Math.cos(phi) * 0.5;

        const c = Math.random() < 0.5 ? palette.base : Math.random() < 0.8 ? palette.analog1 : palette.accent;
        pColors[i * 3] = c.r;
        pColors[i * 3 + 1] = c.g;
        pColors[i * 3 + 2] = c.b;
      }

      pGeo.setAttribute('position', new THREE.BufferAttribute(pPos, 3));
      pGeo.setAttribute('color', new THREE.BufferAttribute(pColors, 3));

      const pMat = new THREE.PointsMaterial({
        size: 1.4,
        map: softTexture,
        vertexColors: true,
        transparent: true,
        opacity: 0.75,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      const pMesh = new THREE.Points(pGeo, pMat);
      group.add(pMesh);
      scene.add(group);

      let time = 0;
      cleanupAnimation = () => {
        discGeo.dispose();
        discs.forEach((d) => d.mat.dispose());
        pGeo.dispose();
        pMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.018;
        }

        const curPal = derivePalette(baseColorRef.current);

        discs.forEach((d, idx) => {
          const breath = Math.sin(time * 0.95 - d.speedOffset);
          const s = d.baseScale * (1 + breath * 0.22);
          d.mesh.scale.set(s, s, s);
          d.mesh.rotation.z = time * (0.04 + idx * 0.015) * (idx % 2 === 0 ? 1 : -1);
          d.mat.color.lerp(idx % 2 === 0 ? curPal.base : curPal.analog1, 0.05);
        });

        pMesh.rotation.z = time * 0.05;
        pMesh.rotation.y = Math.sin(time * 0.2) * 0.15;

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 2. FLOATING ORBS (Smooth Iridescent Floating Bokeh Spheres)
    // =========================================================================
    else if (animation === 'orbs') {
      const palette = derivePalette(baseColorRef.current);
      const orbsCount = 32;
      const orbs: { mesh: THREE.Mesh; vel: THREE.Vector3; baseScale: number; pulseSpeed: number; mat: THREE.MeshBasicMaterial }[] = [];

      // High-segment smooth sphere geometry
      const sphereGeo = new THREE.SphereGeometry(1, 48, 48);

      for (let i = 0; i < orbsCount; i++) {
        // Diverse harmonic gradient blending: base, analog, accent, tint
        const color =
          i % 4 === 0
            ? palette.base
            : i % 4 === 1
            ? palette.analog1
            : i % 4 === 2
            ? palette.analog2
            : palette.accent;

        const mat = new THREE.MeshBasicMaterial({
          color: color.clone(),
          transparent: true,
          opacity: 0.25 + Math.random() * 0.35,
          blending: THREE.AdditiveBlending,
          depthWrite: false,
        });

        const mesh = new THREE.Mesh(sphereGeo, mat);
        const radius = 1.4 + Math.random() * 3.4;
        mesh.scale.set(radius, radius, radius);

        mesh.position.set(
          (Math.random() - 0.5) * 44,
          (Math.random() - 0.5) * 32,
          (Math.random() - 0.5) * 16
        );

        const vel = new THREE.Vector3(
          (Math.random() - 0.5) * 0.03,
          (Math.random() - 0.5) * 0.03,
          (Math.random() - 0.5) * 0.015
        );

        scene.add(mesh);
        orbs.push({ mesh, vel, baseScale: radius, pulseSpeed: 0.8 + Math.random() * 1.5, mat });
      }

      let time = 0;
      cleanupAnimation = () => {
        sphereGeo.dispose();
        orbs.forEach((o) => o.mat.dispose());
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
          const curPal = derivePalette(baseColorRef.current);

          orbs.forEach((orb, i) => {
            orb.mesh.position.add(orb.vel);

            // Smooth organic scaling pulse
            const pulse = 1 + Math.sin(time * orb.pulseSpeed + i) * 0.14;
            orb.mesh.scale.set(orb.baseScale * pulse, orb.baseScale * pulse, orb.baseScale * pulse);

            // Soft bounded turnaround
            if (Math.abs(orb.mesh.position.x) > 26) orb.vel.x *= -1;
            if (Math.abs(orb.mesh.position.y) > 20) orb.vel.y *= -1;
            if (Math.abs(orb.mesh.position.z) > 12) orb.vel.z *= -1;

            const targetColor = i % 4 === 0 ? curPal.base : i % 4 === 1 ? curPal.analog1 : curPal.accent;
            orb.mat.color.lerp(targetColor, 0.04);
          });
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 3. FLUID AURORA (Silky Multi-Hued Harmonic Wave Ribbon)
    // =========================================================================
    else if (animation === 'aurora') {
      const palette = derivePalette(baseColorRef.current);

      // Create a dense, silky-smooth surface grid (80x80)
      const rows = 80;
      const cols = 80;
      const planeGeo = new THREE.PlaneGeometry(60, 50, cols - 1, rows - 1);
      planeGeo.rotateX(-Math.PI / 2.6);

      const count = planeGeo.attributes.position.count;
      const colors = new Float32Array(count * 3);

      for (let i = 0; i < count; i++) {
        const u = (i % cols) / cols;
        const v = Math.floor(i / cols) / rows;
        // Interpolate along ribbon from anchor base to analog1 and accent
        const c = new THREE.Color().copy(palette.base).lerp(palette.analog1, u).lerp(palette.accent, v * 0.6);
        colors[i * 3] = c.r;
        colors[i * 3 + 1] = c.g;
        colors[i * 3 + 2] = c.b;
      }
      planeGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

      // Use smooth shaded additive material with vertex colors
      const planeMat = new THREE.MeshBasicMaterial({
        vertexColors: true,
        transparent: true,
        opacity: 0.45,
        wireframe: false,
        side: THREE.DoubleSide,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      const planeMesh = new THREE.Mesh(planeGeo, planeMat);
      planeMesh.position.y = -5;
      scene.add(planeMesh);

      // Delicate ethereal shimmer contour lines
      const wireMat = new THREE.MeshBasicMaterial({
        color: palette.tint,
        wireframe: true,
        transparent: true,
        opacity: 0.12,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });
      const wireMesh = new THREE.Mesh(planeGeo.clone(), wireMat);
      wireMesh.position.y = -4.9;
      scene.add(wireMesh);

      const posAttr = planeGeo.attributes.position;
      const colorAttr = planeGeo.attributes.color;

      let time = 0;
      cleanupAnimation = () => {
        planeGeo.dispose();
        planeMat.dispose();
        wireMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.018;
          const curPal = derivePalette(baseColorRef.current);

          for (let i = 0; i < posAttr.count; i++) {
            const x = posAttr.getX(i);
            const y = posAttr.getY(i);

            // Silky liquid harmonic equation
            const z =
              Math.sin(x * 0.14 + time * 1.1) * 3.2 +
              Math.cos(y * 0.16 + time * 0.9) * 2.8 +
              Math.sin((x + y) * 0.09 + time * 1.3) * 1.8;
            posAttr.setZ(i, z);

            // Dynamically blend hues based on undulating crest height
            const heightRatio = (z + 6) / 12;
            const dynamicColor = new THREE.Color()
              .copy(curPal.base)
              .lerp(curPal.analog1, Math.min(1, Math.max(0, heightRatio)))
              .lerp(curPal.accent, Math.sin(time + x * 0.05) * 0.3 + 0.3);

            colorAttr.setXYZ(i, dynamicColor.r, dynamicColor.g, dynamicColor.b);
          }
          posAttr.needsUpdate = true;
          colorAttr.needsUpdate = true;

          planeMesh.rotation.z = Math.sin(time * 0.2) * 0.08;
          wireMesh.rotation.z = planeMesh.rotation.z;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 4. COSMIC STARLIGHT (Multi-Hued Nebula Bloom with Twinkling Starlight)
    // =========================================================================
    else if (animation === 'stars') {
      const palette = derivePalette(baseColorRef.current);
      const starCount = 1400;
      const starGeo = new THREE.BufferGeometry();
      const positions = new Float32Array(starCount * 3);
      const colors = new Float32Array(starCount * 3);
      const speeds = new Float32Array(starCount);

      for (let i = 0; i < starCount; i++) {
        positions[i * 3] = (Math.random() - 0.5) * 75;
        positions[i * 3 + 1] = (Math.random() - 0.5) * 55;
        positions[i * 3 + 2] = (Math.random() - 0.5) * 60;
        speeds[i] = 0.04 + Math.random() * 0.08;

        // Rich celestial chromatic spectrum (warm anchor, cyan/violet accents, bright white)
        const c =
          i % 5 === 0
            ? palette.base
            : i % 5 === 1
            ? palette.analog1
            : i % 5 === 2
            ? palette.accent
            : i % 5 === 3
            ? palette.tint
            : new THREE.Color(0xffffff);

        colors[i * 3] = c.r;
        colors[i * 3 + 1] = c.g;
        colors[i * 3 + 2] = c.b;
      }

      starGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
      starGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

      const starMat = new THREE.PointsMaterial({
        size: 1.5,
        map: softTexture,
        vertexColors: true,
        transparent: true,
        opacity: 0.9,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      const starField = new THREE.Points(starGeo, starMat);
      scene.add(starField);

      // Deep celestial glowing nebula dust clouds in background
      const nebulaCount = 4;
      const nebulaGroup = new THREE.Group();
      const nebulaGeo = new THREE.PlaneGeometry(35, 35);
      const nebulaMats: THREE.MeshBasicMaterial[] = [];

      for (let i = 0; i < nebulaCount; i++) {
        const nCol = i === 0 ? palette.base : i === 1 ? palette.analog1 : palette.accent;
        const nMat = new THREE.MeshBasicMaterial({
          map: softTexture,
          color: nCol,
          transparent: true,
          opacity: 0.16,
          blending: THREE.AdditiveBlending,
          depthWrite: false,
        });
        nebulaMats.push(nMat);
        const nMesh = new THREE.Mesh(nebulaGeo, nMat);
        nMesh.position.set((i - 1.5) * 12, (Math.random() - 0.5) * 14, -18);
        nebulaGroup.add(nMesh);
      }
      scene.add(nebulaGroup);

      let time = 0;
      cleanupAnimation = () => {
        starGeo.dispose();
        starMat.dispose();
        nebulaGeo.dispose();
        nebulaMats.forEach((m) => m.dispose());
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
          const pos = starGeo.attributes.position as THREE.BufferAttribute;
          for (let i = 0; i < starCount; i++) {
            let z = pos.getZ(i);
            z += speeds[i];
            if (z > 24) z = -36;
            pos.setZ(i, z);
          }
          pos.needsUpdate = true;
          starField.rotation.y = time * 0.025;
          nebulaGroup.rotation.z = Math.sin(time * 0.1) * 0.05;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 5. HYPERSPACE WARP (Fluid Chromatic Streamlines)
    // =========================================================================
    else if (animation === 'warp') {
      const palette = derivePalette(baseColorRef.current);
      const streakCount = 550;
      const linePositions = new Float32Array(streakCount * 6);
      const lineColors = new Float32Array(streakCount * 6);
      const lineSpeeds = new Float32Array(streakCount);

      for (let i = 0; i < streakCount; i++) {
        const idx = i * 6;
        const angle = Math.random() * Math.PI * 2;
        const radius = 2.5 + Math.random() * 16;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        const z = -65 + Math.random() * 85;

        linePositions[idx] = x;
        linePositions[idx + 1] = y;
        linePositions[idx + 2] = z;

        linePositions[idx + 3] = x;
        linePositions[idx + 4] = y;
        linePositions[idx + 5] = z - (3.5 + Math.random() * 6); // Smooth streak length

        lineSpeeds[i] = 0.55 + Math.random() * 0.85;

        // Vivid gradient along streaks
        const c1 = i % 3 === 0 ? palette.base : i % 3 === 1 ? palette.analog1 : palette.accent;
        const c2 = palette.tint;

        lineColors[idx] = c1.r;
        lineColors[idx + 1] = c1.g;
        lineColors[idx + 2] = c1.b;

        lineColors[idx + 3] = c2.r;
        lineColors[idx + 4] = c2.g;
        lineColors[idx + 5] = c2.b;
      }

      const lineGeo = new THREE.BufferGeometry();
      lineGeo.setAttribute('position', new THREE.BufferAttribute(linePositions, 3));
      lineGeo.setAttribute('color', new THREE.BufferAttribute(lineColors, 3));

      const lineMat = new THREE.LineBasicMaterial({
        vertexColors: true,
        transparent: true,
        opacity: 0.85,
        blending: THREE.AdditiveBlending,
      });

      const lineSegments = new THREE.LineSegments(lineGeo, lineMat);
      scene.add(lineSegments);

      let time = 0;
      cleanupAnimation = () => {
        lineGeo.dispose();
        lineMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
          const pos = lineGeo.attributes.position as THREE.BufferAttribute;
          for (let i = 0; i < streakCount; i++) {
            const idx = i * 6;
            let z1 = pos.getZ(idx);
            let z2 = pos.getZ(idx + 1);

            z1 += lineSpeeds[i];
            z2 += lineSpeeds[i];

            if (z2 > 25) {
              z1 = -70;
              z2 = z1 - 5;
            }

            pos.setZ(idx, z1);
            pos.setZ(idx + 1, z2);
          }
          pos.needsUpdate = true;
          lineSegments.rotation.z = time * 0.08;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 6. CYBER MATRIX RAIN (Fluid Chromatic Data Waterfalls with Soft Particle Glow)
    // =========================================================================
    else if (animation === 'matrix') {
      const palette = derivePalette(baseColorRef.current);
      const colCount = 50;
      const ptsPerCol = 22;
      const totalPoints = colCount * ptsPerCol;
      const positions = new Float32Array(totalPoints * 3);
      const colors = new Float32Array(totalPoints * 3);
      const colX = new Float32Array(colCount);
      const colZ = new Float32Array(colCount);
      const colSpeed = new Float32Array(colCount);
      const colYOffset = new Float32Array(colCount);

      for (let c = 0; c < colCount; c++) {
        colX[c] = (c / colCount - 0.5) * 52;
        colZ[c] = (Math.random() - 0.5) * 16;
        colSpeed[c] = 0.22 + Math.random() * 0.35;
        colYOffset[c] = Math.random() * 35;
      }

      for (let i = 0; i < totalPoints; i++) {
        const ptInCol = i % ptsPerCol;
        // Top of stream has accent pop; rest transitions to anchor base
        const ratio = ptInCol / ptsPerCol;
        const color = ratio < 0.2 ? palette.accent : ratio < 0.6 ? palette.analog1 : palette.base;
        colors[i * 3] = color.r;
        colors[i * 3 + 1] = color.g;
        colors[i * 3 + 2] = color.b;
      }

      const matGeo = new THREE.BufferGeometry();
      matGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
      matGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

      const pointsMat = new THREE.PointsMaterial({
        size: 1.3,
        map: softTexture,
        vertexColors: true,
        transparent: true,
        opacity: 0.85,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      const matrixPoints = new THREE.Points(matGeo, pointsMat);
      scene.add(matrixPoints);

      cleanupAnimation = () => {
        matGeo.dispose();
        pointsMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          const pos = matGeo.attributes.position as THREE.BufferAttribute;
          let pIdx = 0;
          for (let c = 0; c < colCount; c++) {
            colYOffset[c] -= colSpeed[c];
            if (colYOffset[c] < -24) {
              colYOffset[c] = 24;
            }

            for (let i = 0; i < ptsPerCol; i++) {
              const y = colYOffset[c] + i * 1.6;
              pos.setXYZ(pIdx, colX[c], y, colZ[c]);
              pIdx++;
            }
          }
          pos.needsUpdate = true;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 7. LIQUID MORPH (Fluid Organic Iridescent Blob with Specular Light)
    // =========================================================================
    else if (animation === 'liquid') {
      const palette = derivePalette(baseColorRef.current);

      // High polygon smooth sphere for organic fluid deformation (64x64)
      const morphGeo = new THREE.SphereGeometry(9, 64, 64);
      const count = morphGeo.attributes.position.count;
      const colors = new Float32Array(count * 3);

      for (let i = 0; i < count; i++) {
        const u = Math.random();
        const c = u < 0.5 ? palette.base : u < 0.8 ? palette.analog1 : palette.accent;
        colors[i * 3] = c.r;
        colors[i * 3 + 1] = c.g;
        colors[i * 3 + 2] = c.b;
      }
      morphGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

      // Iridescent smooth-shaded mesh with transmission & soft sheen
      const morphMat = new THREE.MeshPhongMaterial({
        vertexColors: true,
        emissive: palette.base,
        emissiveIntensity: 0.35,
        specular: 0xffffff,
        shininess: 120,
        transparent: true,
        opacity: 0.65,
        wireframe: false,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      const morphMesh = new THREE.Mesh(morphGeo, morphMat);
      scene.add(morphMesh);

      // Multiple colored orbiting point lights for rich chromatic highlights
      const light1 = new THREE.PointLight(palette.accent, 4, 60);
      light1.position.set(16, 16, 20);
      scene.add(light1);

      const light2 = new THREE.PointLight(palette.analog1, 3.5, 60);
      light2.position.set(-16, -12, 15);
      scene.add(light2);

      const light3 = new THREE.PointLight(palette.tint, 2, 40);
      light3.position.set(0, 18, -10);
      scene.add(light3);

      const pos = morphGeo.attributes.position;
      const originalPositions = new Float32Array(pos.array);

      let time = 0;
      cleanupAnimation = () => {
        morphGeo.dispose();
        morphMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.02;
          const curPal = derivePalette(baseColorRef.current);

          for (let i = 0; i < pos.count; i++) {
            const ix = i * 3;
            const ox = originalPositions[ix];
            const oy = originalPositions[ix + 1];
            const oz = originalPositions[ix + 2];

            // Smooth undulating harmonic sine/cosine wave
            const wave =
              Math.sin(ox * 0.28 + time * 1.2) *
              Math.cos(oy * 0.28 + time * 0.9) *
              Math.sin(oz * 0.28 + time * 1.1);

            const factor = 1 + wave * 0.18;
            pos.setXYZ(i, ox * factor, oy * factor, oz * factor);
          }
          pos.needsUpdate = true;
          morphGeo.computeVertexNormals();

          morphMesh.rotation.y = time * 0.15;
          morphMesh.rotation.x = time * 0.1;

          // Orbit lights for shimmering reflections
          light1.position.x = Math.sin(time * 0.5) * 22;
          light1.position.y = Math.cos(time * 0.5) * 18;
          light2.position.x = -Math.sin(time * 0.4) * 22;
          light2.color.copy(curPal.analog1);
          light1.color.copy(curPal.accent);
          morphMat.emissive.copy(curPal.base);
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // Window Resize Handler
    const handleResize = () => {
      if (!containerRef.current) return;
      const w = containerRef.current.clientWidth || window.innerWidth;
      const h = containerRef.current.clientHeight || window.innerHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
      cleanupAnimation();
      renderer.dispose();
      if (container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
    };
  }, [animation]);

  if (animation === 'none') {
    return null;
  }

  return (
    <div
      ref={containerRef}
      className={`absolute inset-0 pointer-events-none overflow-hidden transition-opacity duration-700 ${
        isRunning ? 'opacity-100' : 'opacity-40'
      }`}
      aria-hidden="true"
    />
  );
};
