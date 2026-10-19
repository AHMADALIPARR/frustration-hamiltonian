/* Copyright (C) 2026 AHMAD ALI PARR
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * Scripted demonstration of the commit law. Not a proof.
 */
#include "fh.h"

#include <stdio.h>
#include <string.h>

static const char *AGENT[] = {"Aether", "Keel", "Vector"};

static int g_fail;

static const char *code_name(FhCode c) {
  switch (c) {
    case FH_OK: return "ok";
    case FH_REJECT_HARD: return "hard";
    case FH_REJECT_AUTH: return "auth";
    case FH_REJECT_VERIFY: return "verify";
    case FH_REJECT_ENERGY: return "energy";
    case FH_REJECT_OVERFLOW: return "overflow";
    case FH_REJECT_DENOM: return "denom";
    case FH_REJECT_MALFORMED: return "malformed";
    case FH_REJECT_INDEX: return "index";
    case FH_REJECT_CERT: return "cert";
    case FH_REJECT_SOLVER: return "solver";
    case FH_REJECT_MUTATION: return "mutation";
    case FH_REJECT_CONFLICT: return "conflict";
  }
  return "unknown";
}

static void show_state(const char *label, const FhState *s) {
  printf("%s\n", label);
  for (int i = 0; i < FH_N; ++i) {
    printf("  %s (%d,%d,%d)\n", AGENT[i], s->x[i], s->y[i], s->z[i]);
  }
  printf("  generation %u\n", s->generation);
}

static void expect_commit(const char *title, const FhModel *m, const FhState *s, const FhState *sp,
                          const FhAuth *a, int want_bit, FhCode want) {
  FhResult r;
  memset(&r, 0, sizeof r);
  int bit = fh_commit(m, s, sp, a, &r);
  char before[64];
  char after[64];
  int fb = fh_q_format(&r.energy_before, before, sizeof before);
  int fa = fh_q_format(&r.energy_after, after, sizeof after);
  const char *mark = (bit == want_bit && r.code == want) ? "ok" : "FAIL";
  if (mark[0] == 'F') ++g_fail;
  printf("%s\n", title);
  printf("  commit %s  %s", bit ? "TRUE" : "FALSE", code_name(r.code));
  if (fb == FH_OK && fa == FH_OK && (r.code == FH_OK || r.code == FH_REJECT_ENERGY || r.code == FH_REJECT_HARD)) {
    printf("  H %s -> %s", before, after);
  }
  if (bit) printf("  gen %u", r.committed.generation);
  printf("  [%s]\n", mark);
}

int main(void) {
  printf("Frustra demo\n");
  printf("Copyright (C) 2026 AHMAD ALI PARR\n");
  printf("SPDX-License-Identifier: AGPL-3.0-or-later\n");
  printf("source https://github.com/AHMADALIPARR/frustration-hamiltonian\n\n");

  FhModel model;
  fh_model_default(&model);

  FhState s;
  memset(&s, 0, sizeof s);
  s.x[0] = 0; s.y[0] = 3; s.z[0] = 0;
  s.x[1] = 2; s.y[1] = 2; s.z[1] = 0;
  s.x[2] = 4; s.y[2] = 4; s.z[2] = 1;
  s.generation = 5;

  FhQ energy;
  char ebuf[64];
  if (fh_energy(&model, &s, &energy) != FH_OK || fh_q_format(&energy, ebuf, sizeof ebuf) != FH_OK) {
    fprintf(stderr, "energy failed\n");
    return 1;
  }
  show_state("start  box 0..7  no contacts", &s);
  printf("  H_F %s\n\n", ebuf);

  FhAuth descent;
  memset(&descent, 0, sizeof descent);
  descent.actor = 0;
  descent.allowed_mask = 0x7;
  descent.generation = 5;
  descent.token = FH_TOKEN;
  descent.descent = 1;

  FhState down = s;
  down.y[0] = 2;
  expect_commit("Aether steps down. Descent required.", &model, &s, &down, &descent, 1, FH_OK);

  FhState up = s;
  up.y[0] = 4;
  expect_commit("Aether steps up. Descent refuses the rise.", &model, &s, &up, &descent, 0, FH_REJECT_ENERGY);

  FhAuth stir = descent;
  stir.descent = 0;
  expect_commit("Same rise with descent off (stir).", &model, &s, &up, &stir, 1, FH_OK);

  FhState pile;
  memset(&pile, 0, sizeof pile);
  pile.x[2] = 3;
  pile.generation = 5;
  expect_commit("Keel onto Aether. Hard failure, energy ignored.", &model, &s, &pile, &descent, 0,
                FH_REJECT_HARD);

  FhAuth bad = descent;
  bad.token = 1;
  expect_commit("Right step, wrong token.", &model, &s, &down, &bad, 0, FH_REJECT_AUTH);

  FhQ broken;
  int rc = fh_q_from_i64(1, 0, &broken);
  printf("Rational 1/0\n  reject %s  [%s]\n", code_name((FhCode)rc), rc == FH_REJECT_DENOM ? "ok" : "FAIL");
  if (rc != FH_REJECT_DENOM) ++g_fail;

  printf("\n%s\n", g_fail ? "demo failed" : "demo passed");
  return g_fail ? 1 : 0;
}
