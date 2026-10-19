// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { BOX } from "./law.js";

const ACCENT = 0xe2a15a;
const PAPER = 0xeceae4;
const STEEL = 0x9aabba;
const TILE = 0x2a3038;

function cell(v) {
  return v - BOX / 2;
}

export function mountScene(canvas) {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
  renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.6));
  renderer.setClearColor(0x0c0d0f, 1);
  renderer.shadowMap.enabled = true;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(40, 1, 0.1, 80);
  camera.position.set(8.6, 7.4, 8.6);

  scene.add(new THREE.AmbientLight(0xffffff, 0.45));
  const key = new THREE.DirectionalLight(0xfff4e6, 2.3);
  key.position.set(6, 11, 4);
  key.castShadow = true;
  scene.add(key);
  const fill = new THREE.DirectionalLight(STEEL, 0.45);
  fill.position.set(-5, 6, -3);
  scene.add(fill);

  const floor = new THREE.Group();
  const tileGeo = new THREE.BoxGeometry(0.92, 0.06, 0.92);
  const tileMat = new THREE.MeshStandardMaterial({ color: TILE, metalness: 0.25, roughness: 0.72 });
  for (let x = 0; x <= BOX; x++) {
    for (let z = 0; z <= BOX; z++) {
      const tile = new THREE.Mesh(tileGeo, tileMat);
      tile.position.set(cell(x), 0, cell(z));
      tile.receiveShadow = true;
      floor.add(tile);
    }
  }
  scene.add(floor);

  const ring = new THREE.Mesh(
    new THREE.RingGeometry(3.55, 3.62, 64),
    new THREE.MeshBasicMaterial({ color: STEEL, side: THREE.DoubleSide }),
  );
  ring.rotation.x = -Math.PI / 2;
  ring.position.y = 0.08;
  scene.add(ring);

  const geos = [
    new THREE.OctahedronGeometry(0.38, 0),
    new THREE.CylinderGeometry(0.28, 0.28, 0.62, 6),
    new THREE.BoxGeometry(0.52, 0.52, 0.52),
  ];
  const agents = geos.map((geo) => {
    const mat = new THREE.MeshStandardMaterial({
      color: PAPER,
      emissive: PAPER,
      emissiveIntensity: 0.16,
      metalness: 0.45,
      roughness: 0.35,
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.castShadow = true;
    scene.add(mesh);
    return mesh;
  });

  const drops = [];
  const dropGeo = new THREE.SphereGeometry(0.22, 18, 14);
  const dropMat = new THREE.MeshStandardMaterial({
    color: ACCENT,
    metalness: 0.25,
    roughness: 0.4,
  });

  const controls = new OrbitControls(camera, canvas);
  controls.target.set(0, 1.2, 0);
  controls.maxPolarAngle = Math.PI / 2.12;
  controls.minDistance = 6;
  controls.maxDistance = 18;
  controls.enableDamping = true;

  const shown = agents.map(() => new THREE.Vector3());
  let lattice = null;
  let actor = 0;
  let ready = false;

  function resize() {
    const w = canvas.clientWidth || 800;
    const h = canvas.clientHeight || 480;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  resize();
  const observer = new ResizeObserver(resize);
  observer.observe(canvas);

  const clock = new THREE.Clock();
  function frame() {
    const dt = Math.min(clock.getDelta(), 0.05);
    if (lattice) {
      for (let i = 0; i < 3; i++) {
        const goal = new THREE.Vector3(
          cell(lattice.x[i]),
          lattice.y[i] * 0.55 + 0.45,
          cell(lattice.z[i]),
        );
        if (!ready) shown[i].copy(goal);
        else shown[i].lerp(goal, 1 - Math.exp(-8 * dt));
        agents[i].position.copy(shown[i]);
        agents[i].rotation.y += dt * (actor === i ? 0.85 : 0.16);
        const hot = actor === i;
        agents[i].material.color.setHex(hot ? ACCENT : PAPER);
        agents[i].material.emissive.setHex(hot ? ACCENT : PAPER);
      }
      ready = true;
    }
    for (let i = drops.length - 1; i >= 0; i--) {
      const d = drops[i];
      d.vel.y -= 9.8 * dt;
      d.mesh.position.addScaledVector(d.vel, dt);
      if (d.mesh.position.y < 0.28) {
        d.mesh.position.y = 0.28;
        d.vel.y = Math.abs(d.vel.y) * 0.42;
        d.vel.x *= 0.86;
        d.vel.z *= 0.86;
        d.bounces++;
      }
      if (d.bounces > 8 && Math.abs(d.vel.y) < 0.15) {
        scene.remove(d.mesh);
        drops.splice(i, 1);
      }
    }
    controls.update();
    renderer.render(scene, camera);
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  return {
    set(next, who) {
      lattice = next;
      actor = who;
    },
    drop() {
      const mesh = new THREE.Mesh(dropGeo, dropMat);
      mesh.castShadow = true;
      const n = drops.length + 1;
      mesh.position.set(((n * 1.7) % 4) - 2, 4.2 + (n % 3) * 0.4, ((n * 0.9) % 4) - 2);
      scene.add(mesh);
      drops.push({
        mesh,
        vel: new THREE.Vector3((n % 3) - 1, 0.2, ((n * 2) % 3) - 1),
        bounces: 0,
      });
    },
    resetMotion() {
      ready = false;
    },
  };
}
