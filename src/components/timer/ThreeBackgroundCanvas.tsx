import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';
import type { BackgroundAnimationId } from '../../types';

interface ThreeBackgroundCanvasProps {
  animation: BackgroundAnimationId;
  isRunning: boolean;
  baseColor: string;
}

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

    // Create Scene, Camera, WebGLRenderer
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(65, width / height, 0.1, 1000);
    camera.position.z = 25;

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

    // Helpers to convert color
    const parseBaseColor = (hex: string) => {
      try {
        return new THREE.Color(hex);
      } catch {
        return new THREE.Color(0xd7195f);
      }
    };

    let cleanupAnimation: () => void = () => {};

    // =========================================================================
    // 1. BREATHING PULSE (3D Concentric Halo Spheres & Particle Dust)
    // =========================================================================
    if (animation === 'breathing') {
      const group = new THREE.Group();

      // Core pulsating energy sphere with wireframe glow
      const coreGeo = new THREE.IcosahedronGeometry(7, 4);
      const coreMat = new THREE.MeshBasicMaterial({
        color: parseBaseColor(baseColorRef.current),
        wireframe: true,
        transparent: true,
        opacity: 0.22,
      });
      const coreMesh = new THREE.Mesh(coreGeo, coreMat);
      group.add(coreMesh);

      // Outer halo rings
      const ringGeo = new THREE.TorusGeometry(12, 0.15, 16, 100);
      const ringMat = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.35,
      });
      const ring1 = new THREE.Mesh(ringGeo, ringMat);
      const ring2 = new THREE.Mesh(ringGeo, ringMat.clone());
      ring2.rotation.x = Math.PI / 2.5;
      group.add(ring1);
      group.add(ring2);

      // Ambient expanding breathing particles
      const particleCount = 450;
      const partGeo = new THREE.BufferGeometry();
      const posArray = new Float32Array(particleCount * 3);
      const scalesArray = new Float32Array(particleCount);

      for (let i = 0; i < particleCount * 3; i += 3) {
        const r = 8 + Math.random() * 20;
        const theta = Math.random() * Math.PI * 2;
        const phi = Math.acos(Math.random() * 2 - 1);
        posArray[i] = r * Math.sin(phi) * Math.cos(theta);
        posArray[i + 1] = r * Math.sin(phi) * Math.sin(theta);
        posArray[i + 2] = r * Math.cos(phi);
        scalesArray[i / 3] = Math.random();
      }

      partGeo.setAttribute('position', new THREE.BufferAttribute(posArray, 3));
      const partMat = new THREE.PointsMaterial({
        size: 0.65,
        color: 0xffffff,
        transparent: true,
        opacity: 0.65,
        blending: THREE.AdditiveBlending,
      });
      const particles = new THREE.Points(partGeo, partMat);
      group.add(particles);

      scene.add(group);

      let time = 0;
      cleanupAnimation = () => {
        coreGeo.dispose();
        coreMat.dispose();
        ringGeo.dispose();
        ringMat.dispose();
        partGeo.dispose();
        partMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
        }

        const breath = Math.sin(time * 0.9); // Calm ~7s breathing loop
        const scale = 1 + breath * 0.22;
        coreMesh.scale.set(scale, scale, scale);
        coreMat.opacity = 0.2 + (breath + 1) * 0.12;

        ring1.rotation.z += 0.003;
        ring1.rotation.y += 0.002;
        ring2.rotation.z -= 0.002;
        ring2.rotation.x += 0.003;

        group.rotation.y = time * 0.08;
        particles.rotation.y = -time * 0.05;

        // Sync color dynamically with theme
        coreMat.color = parseBaseColor(baseColorRef.current);

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 2. FLOATING ORBS (3D Luminous Floating Glass Spheres with Specular Light)
    // =========================================================================
    else if (animation === 'orbs') {
      const orbsCount = 28;
      const orbs: { mesh: THREE.Mesh; speed: THREE.Vector3; initialPos: THREE.Vector3 }[] = [];
      const sphereGeo = new THREE.SphereGeometry(1, 32, 32);

      // Point lights for gorgeous specular highlights
      const light1 = new THREE.PointLight(0xffffff, 2.5, 60);
      light1.position.set(10, 15, 20);
      scene.add(light1);

      const light2 = new THREE.PointLight(parseBaseColor(baseColorRef.current), 3, 50);
      light2.position.set(-15, -10, 10);
      scene.add(light2);

      for (let i = 0; i < orbsCount; i++) {
        const mat = new THREE.MeshPhongMaterial({
          color: 0xffffff,
          emissive: parseBaseColor(baseColorRef.current),
          emissiveIntensity: 0.25,
          specular: 0xffffff,
          shininess: 90,
          transparent: true,
          opacity: 0.45 + Math.random() * 0.35,
          blending: THREE.AdditiveBlending,
        });

        const mesh = new THREE.Mesh(sphereGeo, mat);
        const radius = 1.2 + Math.random() * 3.2;
        mesh.scale.set(radius, radius, radius);

        const pos = new THREE.Vector3(
          (Math.random() - 0.5) * 45,
          (Math.random() - 0.5) * 35,
          (Math.random() - 0.5) * 25
        );
        mesh.position.copy(pos);

        const speed = new THREE.Vector3(
          (Math.random() - 0.5) * 0.035,
          (Math.random() - 0.5) * 0.035,
          (Math.random() - 0.5) * 0.02
        );

        scene.add(mesh);
        orbs.push({ mesh, speed, initialPos: pos.clone() });
      }

      let time = 0;
      cleanupAnimation = () => {
        sphereGeo.dispose();
        orbs.forEach((o) => (o.mesh.material as THREE.Material).dispose());
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
          orbs.forEach((orb) => {
            orb.mesh.position.add(orb.speed);
            orb.mesh.rotation.x += 0.005;
            orb.mesh.rotation.y += 0.005;

            // Soft boundary bounce
            if (Math.abs(orb.mesh.position.x) > 28) orb.speed.x *= -1;
            if (Math.abs(orb.mesh.position.y) > 22) orb.speed.y *= -1;
            if (Math.abs(orb.mesh.position.z) > 18) orb.speed.z *= -1;
          });
        }

        light2.color = parseBaseColor(baseColorRef.current);
        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 3. FLUID AURORA (Dynamic 3D Waving Parametric Ribbon Surface)
    // =========================================================================
    else if (animation === 'aurora') {
      const rows = 65;
      const cols = 65;
      const planeGeo = new THREE.PlaneGeometry(65, 55, cols - 1, rows - 1);
      planeGeo.rotateX(-Math.PI / 3);

      const planeMat = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        wireframe: true,
        transparent: true,
        opacity: 0.35,
        blending: THREE.AdditiveBlending,
      });

      const planeMesh = new THREE.Mesh(planeGeo, planeMat);
      planeMesh.position.y = -6;
      scene.add(planeMesh);

      // Secondary floating shimmer plane
      const planeMat2 = new THREE.MeshBasicMaterial({
        color: parseBaseColor(baseColorRef.current),
        wireframe: true,
        transparent: true,
        opacity: 0.28,
        blending: THREE.AdditiveBlending,
      });
      const planeMesh2 = new THREE.Mesh(planeGeo.clone(), planeMat2);
      planeMesh2.position.y = -3;
      planeMesh2.rotation.z = Math.PI / 4;
      scene.add(planeMesh2);

      const posAttr = planeGeo.attributes.position;
      const originalZ = new Float32Array(posAttr.count);
      for (let i = 0; i < posAttr.count; i++) {
        originalZ[i] = posAttr.getZ(i);
      }

      let time = 0;
      cleanupAnimation = () => {
        planeGeo.dispose();
        planeMat.dispose();
        planeMat2.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.02;
          for (let i = 0; i < posAttr.count; i++) {
            const x = posAttr.getX(i);
            const y = posAttr.getY(i);
            const z =
              Math.sin(x * 0.18 + time) * 3.5 +
              Math.cos(y * 0.18 + time * 1.2) * 3.5 +
              Math.sin((x + y) * 0.1 + time * 0.8) * 2;
            posAttr.setZ(i, z);
          }
          posAttr.needsUpdate = true;
        }

        planeMesh.rotation.z = Math.sin(time * 0.1) * 0.15;
        planeMat2.color = parseBaseColor(baseColorRef.current);
        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 4. COSMIC STARFIELD (3D Twinkling Volumetric Stars with Depth Drift)
    // =========================================================================
    else if (animation === 'stars') {
      const starCount = 1800;
      const starGeo = new THREE.BufferGeometry();
      const positions = new Float32Array(starCount * 3);
      const velocities = new Float32Array(starCount);

      for (let i = 0; i < starCount * 3; i += 3) {
        positions[i] = (Math.random() - 0.5) * 80;
        positions[i + 1] = (Math.random() - 0.5) * 60;
        positions[i + 2] = (Math.random() - 0.5) * 80;
        velocities[i / 3] = 0.05 + Math.random() * 0.12;
      }

      starGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));

      const starMat = new THREE.PointsMaterial({
        color: 0xffffff,
        size: 0.8,
        transparent: true,
        opacity: 0.85,
        blending: THREE.AdditiveBlending,
      });

      const starField = new THREE.Points(starGeo, starMat);
      scene.add(starField);

      let time = 0;
      cleanupAnimation = () => {
        starGeo.dispose();
        starMat.dispose();
      };

      const animate = () => {
        animationFrameRef.current = requestAnimationFrame(animate);

        if (isRunningRef.current) {
          time += 0.016;
          const pos = starGeo.attributes.position as THREE.BufferAttribute;
          for (let i = 0; i < starCount; i++) {
            let z = pos.getZ(i);
            z += velocities[i];
            if (z > 30) {
              z = -50;
            }
            pos.setZ(i, z);
          }
          pos.needsUpdate = true;
          starField.rotation.y = time * 0.02;
          starField.rotation.x = Math.sin(time * 0.05) * 0.05;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 5. HYPERSPACE WARP TUNNEL (High-speed 3D Warp Streaks)
    // =========================================================================
    else if (animation === 'warp') {
      const streakCount = 850;
      const linePositions = new Float32Array(streakCount * 6);
      const lineSpeeds = new Float32Array(streakCount);

      for (let i = 0; i < streakCount; i++) {
        const idx = i * 6;
        const angle = Math.random() * Math.PI * 2;
        const radius = 2 + Math.random() * 18;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        const z = -60 + Math.random() * 80;

        linePositions[idx] = x;
        linePositions[idx + 1] = y;
        linePositions[idx + 2] = z;

        linePositions[idx + 3] = x;
        linePositions[idx + 4] = y;
        linePositions[idx + 5] = z - (2 + Math.random() * 5); // Length of streak

        lineSpeeds[i] = 0.5 + Math.random() * 0.9;
      }

      const lineGeo = new THREE.BufferGeometry();
      lineGeo.setAttribute('position', new THREE.BufferAttribute(linePositions, 3));

      const lineMat = new THREE.LineBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.75,
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
              z1 = -65;
              z2 = z1 - 4;
            }

            pos.setZ(idx, z1);
            pos.setZ(idx + 1, z2);
          }
          pos.needsUpdate = true;
          lineSegments.rotation.z += 0.003;
        }

        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 6. CYBER MATRIX RAIN (3D Cascading Cyber Columns with Glow)
    // =========================================================================
    else if (animation === 'matrix') {
      const columnCount = 55;
      const pointsPerCol = 25;
      const totalPoints = columnCount * pointsPerCol;
      const positions = new Float32Array(totalPoints * 3);
      const colX = new Float32Array(columnCount);
      const colZ = new Float32Array(columnCount);
      const colSpeed = new Float32Array(columnCount);
      const colYOffset = new Float32Array(columnCount);

      for (let c = 0; c < columnCount; c++) {
        colX[c] = (c / columnCount - 0.5) * 55;
        colZ[c] = (Math.random() - 0.5) * 20;
        colSpeed[c] = 0.25 + Math.random() * 0.45;
        colYOffset[c] = Math.random() * 40;
      }

      const matGeo = new THREE.BufferGeometry();
      matGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));

      const pointsMat = new THREE.PointsMaterial({
        color: 0xffffff,
        size: 0.95,
        transparent: true,
        opacity: 0.85,
        blending: THREE.AdditiveBlending,
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
          for (let c = 0; c < columnCount; c++) {
            colYOffset[c] -= colSpeed[c];
            if (colYOffset[c] < -25) {
              colYOffset[c] = 25;
            }

            for (let i = 0; i < pointsPerCol; i++) {
              const y = colYOffset[c] + i * 1.5;
              pos.setXYZ(pIdx, colX[c], y, colZ[c]);
              pIdx++;
            }
          }
          pos.needsUpdate = true;
        }

        pointsMat.color = parseBaseColor(baseColorRef.current);
        renderer.render(scene, camera);
      };
      animate();
    }

    // =========================================================================
    // 7. LIQUID MORPH SPHERE (Distorting 3D Organic Noise Mesh)
    // =========================================================================
    else if (animation === 'liquid') {
      const morphGeo = new THREE.IcosahedronGeometry(10, 32);
      const morphMat = new THREE.MeshPhongMaterial({
        color: 0xffffff,
        emissive: parseBaseColor(baseColorRef.current),
        emissiveIntensity: 0.45,
        wireframe: true,
        transparent: true,
        opacity: 0.45,
        blending: THREE.AdditiveBlending,
      });

      const morphMesh = new THREE.Mesh(morphGeo, morphMat);
      scene.add(morphMesh);

      // Light
      const pLight = new THREE.PointLight(0xffffff, 3, 50);
      pLight.position.set(15, 15, 20);
      scene.add(pLight);

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
          for (let i = 0; i < pos.count; i++) {
            const ix = i * 3;
            const ox = originalPositions[ix];
            const oy = originalPositions[ix + 1];
            const oz = originalPositions[ix + 2];

            const wave =
              Math.sin(ox * 0.35 + time) *
              Math.cos(oy * 0.35 + time * 0.8) *
              Math.sin(oz * 0.35 + time * 1.2);

            const factor = 1 + wave * 0.28;
            pos.setXYZ(i, ox * factor, oy * factor, oz * factor);
          }
          pos.needsUpdate = true;
          morphMesh.rotation.y = time * 0.15;
          morphMesh.rotation.x = time * 0.1;
        }

        morphMat.emissive = parseBaseColor(baseColorRef.current);
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
