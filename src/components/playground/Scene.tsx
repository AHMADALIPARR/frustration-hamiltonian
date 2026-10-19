import { Canvas, useFrame } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";
import { Physics, RigidBody } from "@react-three/rapier";
import { useMemo, useRef } from "react";
import type { Mesh } from "three";
import { Vector3 } from "three";
import { BOX, type Lattice } from "@/game/kernel";

type Drop = { id: number; position: [number, number, number] };

function cssColor(name: string, fallback: string) {
  if (typeof document === "undefined") return fallback;
  const raw = getComputedStyle(document.documentElement).getPropertyValue(name).trim();
  return raw || fallback;
}

export function usePalette() {
  return useMemo(
    () => ({
      bg: cssColor("--color-bg", "#0c0d0f"),
      surface: cssColor("--color-surface", "#14161a"),
      fg: cssColor("--color-fg", "#eceae4"),
      muted: cssColor("--color-muted", "#9aabba"),
      accent: cssColor("--color-accent", "#e2a15a"),
    }),
    [],
  );
}

function cell(v: number) {
  return v - BOX / 2;
}

function AgentBody({
  index,
  lattice,
  active,
  color,
  muted,
}: {
  index: number;
  lattice: Lattice;
  active: boolean;
  color: string;
  muted: string;
}) {
  const ref = useRef<Mesh>(null);
  const shown = useRef(new Vector3());
  const goal = useRef(new Vector3());
  useFrame((_, delta) => {
    const mesh = ref.current;
    if (!mesh) return;
    const dt = Math.min(delta, 0.05);
    if (shown.current.lengthSq() === 0 && mesh.position.lengthSq() === 0) {
      mesh.position.set(cell(lattice.x[index]), lattice.y[index] * 0.55 + 0.45, cell(lattice.z[index]));
    }
    goal.current.set(cell(lattice.x[index]), lattice.y[index] * 0.55 + 0.45, cell(lattice.z[index]));
    mesh.position.lerp(goal.current, 1 - Math.exp(-8 * dt));
    mesh.rotation.y += dt * (active ? 0.8 : 0.15);
  });
  const tint = active ? color : muted;
  return (
    <mesh ref={ref} castShadow>
      {index === 0 ? (
        <octahedronGeometry args={[0.38, 0]} />
      ) : index === 1 ? (
        <cylinderGeometry args={[0.28, 0.28, 0.62, 6]} />
      ) : (
        <boxGeometry args={[0.52, 0.52, 0.52]} />
      )}
      <meshStandardMaterial color={tint} emissive={tint} emissiveIntensity={0.18} metalness={0.45} roughness={0.35} />
    </mesh>
  );
}

function Floor({ muted }: { muted: string }) {
  const tiles = [];
  for (let x = 0; x <= BOX; x++) {
    for (let z = 0; z <= BOX; z++) {
      tiles.push(
        <mesh key={`${x}-${z}`} position={[cell(x), 0, cell(z)]} receiveShadow>
          <boxGeometry args={[0.92, 0.06, 0.92]} />
          <meshStandardMaterial color="#2a3038" metalness={0.25} roughness={0.7} />
        </mesh>,
      );
    }
  }
  return (
    <group>
      {tiles}
      <mesh position={[0, 0.08, 0]}>
        <ringGeometry args={[3.6, 3.66, 48]} />
        <meshBasicMaterial color={muted} />
      </mesh>
    </group>
  );
}

export function SceneView({
  lattice,
  actor,
  drops,
}: {
  lattice: Lattice;
  actor: number;
  drops: Drop[];
}) {
  const palette = usePalette();
  return (
    <Canvas shadows camera={{ position: [8.5, 7.2, 8.5], fov: 40 }} dpr={[1, 1.6]}>
      <color attach="background" args={[palette.bg]} />
      <ambientLight intensity={0.45} />
      <directionalLight position={[6, 10, 4]} intensity={2.2} castShadow />
      <directionalLight position={[-4, 6, -2]} intensity={0.4} color={palette.muted} />
      <Physics gravity={[0, -9.81, 0]}>
        <RigidBody type="fixed" colliders="cuboid" position={[0, -0.2, 0]}>
          <mesh>
            <boxGeometry args={[12, 0.3, 12]} />
            <meshStandardMaterial color={palette.bg} />
          </mesh>
        </RigidBody>
        <Floor muted={palette.muted} />
        {drops.map((d) => (
          <RigidBody key={d.id} position={d.position} colliders="ball" restitution={0.45}>
            <mesh castShadow>
              <sphereGeometry args={[0.28, 20, 16]} />
              <meshStandardMaterial color={palette.accent} metalness={0.2} roughness={0.4} />
            </mesh>
          </RigidBody>
        ))}
      </Physics>
      {[0, 1, 2].map((i) => (
        <AgentBody
          key={i}
          index={i}
          lattice={lattice}
          active={actor === i}
          color={palette.accent}
          muted={palette.fg}
        />
      ))}
      <OrbitControls target={[0, 1.2, 0]} maxPolarAngle={Math.PI / 2.15} minDistance={6} maxDistance={18} />
    </Canvas>
  );
}
