import { Pause, Play, RotateCcw } from "lucide-react";
import { useEffect, useRef, useState, type ComponentType } from "react";
import {
  AGENTS,
  BOX,
  certBound,
  certOverlap,
  certPigeon,
  clone,
  commit,
  energy,
  formatEnergy,
  hardValid,
  initial,
  propose,
  type Lattice,
  type Verdict,
} from "@/game/kernel";

type Phase = "scout" | "measure" | "commit";
type Drop = { id: number; position: [number, number, number] };

const PHASES: Phase[] = ["scout", "measure", "commit"];

function LatticeView({
  lattice,
  actor,
  drops,
}: {
  lattice: Lattice;
  actor: number;
  drops: Drop[];
}) {
  const [View, setView] = useState<ComponentType<{
    lattice: Lattice;
    actor: number;
    drops: Drop[];
  }> | null>(null);
  useEffect(() => {
    void import("./Scene").then((m) => setView(() => m.SceneView));
  }, []);
  if (!View) {
    return (
      <div className="grid h-full place-items-center bg-bg font-mono text-xs tracking-[0.16em] text-muted">
        raising the lattice
      </div>
    );
  }
  return <View lattice={lattice} actor={actor} drops={drops} />;
}


function tone(code: Verdict) {
  if (code === "ok") return "text-accent";
  return "text-muted";
}

export function Pit() {
  const [lattice, setLattice] = useState<Lattice>(initial);
  const [phase, setPhase] = useState<Phase>("scout");
  const [descent, setDescent] = useState(true);
  const [running, setRunning] = useState(true);
  const [actor, setActor] = useState(0);
  const [proposal, setProposal] = useState<Lattice>(() => initial());
  const [last, setLast] = useState<Verdict>("ok");
  const [log, setLog] = useState<string[]>(["pit armed · descent law on"]);
  const [drops, setDrops] = useState<Drop[]>([]);
  const [certNote, setCertNote] = useState("no certificate");
  const id = useRef(1);

  const h = energy(lattice);

  function push(line: string) {
    setLog((prev) => [line, ...prev].slice(0, 7));
  }

  function step() {
    if (phase === "scout") {
      const who = lattice.generation % 3;
      const next = propose(lattice, who, descent);
      setActor(who);
      setProposal(next);
      setPhase("measure");
      push(`${AGENTS[who]} scouts a ${descent ? "descent" : "stir"} step`);
      return;
    }
    if (phase === "measure") {
      const after = energy(proposal);
      const hard = hardValid(proposal);
      setPhase("commit");
      push(`Keel measures H ${formatEnergy(h)} → ${formatEnergy(after)} · hard ${hard ? "holds" : "fails"}`);
      return;
    }
    const out = commit(lattice, proposal, actor, descent);
    setLast(out.code);
    if (out.ok && out.next) {
      setLattice(out.next);
      push(`Vector commits · generation ${out.next.generation} · H ${formatEnergy(out.after)}`);
    } else {
      push(`Vector rejects ${out.code} · boolean FALSE`);
    }
    setPhase("scout");
  }

  const stepRef = useRef(step);
  stepRef.current = step;
  useEffect(() => {
    if (!running) return;
    const timer = window.setInterval(() => stepRef.current(), 1100);
    return () => window.clearInterval(timer);
  }, [running]);

  function nudge(axis: "x" | "y" | "z", dir: number) {
    const t = clone(lattice);
    t[axis][actor] += dir;
    const out = commit(lattice, t, actor, descent);
    setLast(out.code);
    if (out.ok && out.next) {
      setLattice(out.next);
      push(`manual ${AGENTS[actor]} ${axis}${dir > 0 ? "+" : "−"} committed`);
    } else {
      push(`manual rejected ${out.code} · FALSE`);
    }
  }

  function showCert(kind: string) {
    if (kind === "bound") {
      const ok = certBound(4, 1);
      setCertNote(ok ? "bound 4>1 proves empty · accepted" : "certificate refused");
    } else if (kind === "pigeon") {
      const ok = certPigeon(5, 4);
      setCertNote(ok ? "5 bodies, 4 cells · infeasible" : "certificate refused");
    } else {
      const ok = certOverlap(0, 1);
      setCertNote(ok ? "forced overlap 0=1 with separation · infeasible" : "certificate refused");
    }
  }

  const contacts =
    Number(Math.abs(lattice.x[0] - lattice.x[1]) + Math.abs(lattice.y[0] - lattice.y[1]) + Math.abs(lattice.z[0] - lattice.z[1]) === 1) +
    Number(Math.abs(lattice.x[0] - lattice.x[2]) + Math.abs(lattice.y[0] - lattice.y[2]) + Math.abs(lattice.z[0] - lattice.z[2]) === 1) +
    Number(Math.abs(lattice.x[1] - lattice.x[2]) + Math.abs(lattice.y[1] - lattice.y[2]) + Math.abs(lattice.z[1] - lattice.z[2]) === 1);

  return (
    <main className="flex min-h-svh flex-col bg-bg text-fg">
      <header className="flex items-end justify-between gap-4 px-4 pt-4 pb-2">
        <div>
          <p className="font-mono text-[11px] tracking-[0.22em] text-muted">SNAPKITTY PIT</p>
          <h1 className="text-2xl font-medium tracking-tight">Frustra</h1>
          <a
            className="font-mono text-[11px] tracking-[0.14em] text-accent"
            href="https://github.com/AHMADALIPARR/frustration-hamiltonian"
          >
            AGPL-3.0 source
          </a>
        </div>
        <div className="text-right">
          <p className="font-mono text-[11px] tracking-[0.16em] text-muted">H_F</p>
          <p className="font-mono text-xl text-accent">{formatEnergy(h)}</p>
        </div>
      </header>

      <div className="relative mx-4 min-h-[48svh] flex-1 overflow-hidden rounded-xl border border-muted/25">
        <LatticeView lattice={lattice} actor={actor} drops={drops} />
        <div className="pointer-events-none absolute top-3 left-3 flex gap-2">
          {PHASES.map((p) => (
            <span
              key={p}
              className={`rounded-full px-2.5 py-1 font-mono text-[11px] tracking-wide ${
                p === phase ? "bg-accent text-bg" : "bg-surface/80 text-muted"
              }`}
            >
              {p}
            </span>
          ))}
        </div>
      </div>

      <section className="grid gap-3 px-4 py-3 sm:grid-cols-[1.2fr_0.8fr]">
        <div className="flex flex-wrap items-center gap-2">
          <button
            type="button"
            className="inline-flex h-11 items-center gap-2 rounded-lg bg-accent px-4 text-sm font-medium text-bg"
            onClick={() => setRunning((v) => !v)}
          >
            {running ? <Pause size={16} /> : <Play size={16} />}
            {running ? "Pause" : "Run"}
          </button>
          <button
            type="button"
            className="inline-flex h-11 items-center rounded-lg border border-muted/30 px-4 text-sm"
            onClick={step}
          >
            Step
          </button>
          <button
            type="button"
            className={`inline-flex h-11 items-center rounded-lg border px-4 text-sm ${
              descent ? "border-accent text-accent" : "border-muted/30 text-muted"
            }`}
            onClick={() => {
              setDescent((v) => !v);
              push(!descent ? "descent constraint on" : "stir mode · ascent allowed");
            }}
          >
            {descent ? "Descent" : "Stir"}
          </button>
          <button
            type="button"
            className="inline-flex h-11 items-center gap-2 rounded-lg border border-muted/30 px-4 text-sm"
            onClick={() => {
              setLattice(initial());
              setPhase("scout");
              setLast("ok");
              setDrops([]);
              push("lattice reset");
            }}
          >
            <RotateCcw size={16} />
            Reset
          </button>
          <button
            type="button"
            className="inline-flex h-11 items-center rounded-lg border border-muted/30 px-4 text-sm"
            onClick={() => {
              const n = id.current++;
              setDrops((d) => [...d, { id: n, position: [((n * 1.7) % 4) - 2, 4 + (n % 3), ((n * 0.9) % 4) - 2] }]);
            }}
          >
            Drop mass
          </button>
        </div>
        <div className="grid grid-cols-3 gap-2">
          {AGENTS.map((name, i) => (
            <button
              key={name}
              type="button"
              onClick={() => setActor(i)}
              className={`h-11 rounded-lg border text-sm ${
                actor === i ? "border-accent text-accent" : "border-muted/30 text-muted"
              }`}
            >
              {name}
            </button>
          ))}
        </div>
      </section>

      <section className="grid grid-cols-3 gap-2 px-4 pb-2 sm:grid-cols-6">
        {(
          [
            ["−X", "x", -1],
            ["+X", "x", 1],
            ["−Y", "y", -1],
            ["+Y", "y", 1],
            ["−Z", "z", -1],
            ["+Z", "z", 1],
          ] as const
        ).map(([label, axis, dir]) => (
          <button
            key={label}
            type="button"
            className="h-11 rounded-lg bg-surface text-sm"
            onClick={() => nudge(axis, dir)}
          >
            {label}
          </button>
        ))}
      </section>

      <section className="grid gap-3 px-4 pb-5 sm:grid-cols-2">
        <div className="rounded-xl bg-surface p-3">
          <div className="mb-2 flex items-center justify-between font-mono text-[11px] tracking-[0.14em] text-muted">
            <span>LEDGER</span>
            <span className={tone(last)}>{last === "ok" ? "TRUE" : "FALSE"}</span>
          </div>
          <ul className="space-y-1 font-mono text-xs text-fg">
            {log.map((line, i) => (
              <li key={`${line}-${i}`} className="truncate">
                {line}
              </li>
            ))}
          </ul>
        </div>
        <div className="rounded-xl bg-surface p-3">
          <p className="font-mono text-[11px] tracking-[0.14em] text-muted">HARD / SOFT</p>
          <p className="mt-2 text-sm text-fg">
            Heights {lattice.y.join(" · ")} · contacts {contacts}
          </p>
          <p className="mt-1 text-sm text-muted">
            Hard cells stay inside 0…{BOX} and never share a site. Soft energy cannot buy a hard violation.
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            <button type="button" className="h-11 rounded-lg border border-muted/30 px-3 text-sm" onClick={() => showCert("bound")}>
              Bound cert
            </button>
            <button type="button" className="h-11 rounded-lg border border-muted/30 px-3 text-sm" onClick={() => showCert("pigeon")}>
              Pigeon
            </button>
            <button type="button" className="h-11 rounded-lg border border-muted/30 px-3 text-sm" onClick={() => showCert("overlap")}>
              Overlap
            </button>
          </div>
          <p className="mt-2 font-mono text-xs text-accent">{certNote}</p>
        </div>
      </section>
    </main>
  );
}
