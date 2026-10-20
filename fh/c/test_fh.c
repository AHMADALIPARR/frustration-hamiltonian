/* Copyright (C) 2026 AHMAD ALI PARR
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "fh.h"

#include <stdio.h>
#include <string.h>

static int g_fail;

static void expect(int cond, const char *msg) {
  if (!cond) {
    fprintf(stderr, "FAIL %s\n", msg);
    ++g_fail;
  }
}

static FhQ q(int64_t n, int64_t d) {
  FhQ out;
  memset(&out, 0, sizeof out);
  int rc = fh_q_from_i64(n, d, &out);
  if (rc != FH_OK) {
    fprintf(stderr, "FAIL from %lld/%lld rc=%d\n", (long long)n, (long long)d, rc);
    ++g_fail;
  }
  return out;
}

static void expect_fmt(const FhQ *a, const char *want, const char *msg) {
  char buf[128];
  int rc = fh_q_format(a, buf, sizeof buf);
  if (rc != FH_OK || strcmp(buf, want) != 0) {
    fprintf(stderr, "FAIL %s got %s (rc %d) want %s\n", msg, buf, rc, want);
    ++g_fail;
  }
}

static FhState state_of(int x0, int y0, int z0, int x1, int y1, int z1, int x2, int y2, int z2,
                        uint32_t gen) {
  FhState s;
  memset(&s, 0, sizeof s);
  s.x[0] = (int16_t)x0;
  s.y[0] = (int16_t)y0;
  s.z[0] = (int16_t)z0;
  s.x[1] = (int16_t)x1;
  s.y[1] = (int16_t)y1;
  s.z[1] = (int16_t)z1;
  s.x[2] = (int16_t)x2;
  s.y[2] = (int16_t)y2;
  s.z[2] = (int16_t)z2;
  s.generation = gen;
  return s;
}

static FhAuth auth_of(uint8_t actor, uint8_t mask, uint32_t gen, uint32_t token, uint8_t descent) {
  FhAuth a;
  memset(&a, 0, sizeof a);
  a.actor = actor;
  a.allowed_mask = mask;
  a.generation = gen;
  a.token = token;
  a.descent = descent;
  return a;
}

static uint32_t checksum(const void *p, size_t n) {
  const unsigned char *b = p;
  uint32_t h = 2166136261u;
  for (size_t i = 0; i < n; ++i) {
    h ^= b[i];
    h *= 16777619u;
  }
  return h;
}

int main(void) {
  FhQ t;
  int rc = fh_q_from_i64(1, 0, &t);
  expect(rc == FH_REJECT_DENOM, "zero denominator");
  rc = fh_q_from_i64(1, 0, &t);
  expect(rc == FH_REJECT_DENOM, "zero denominator repeat");

  t = q(3, -6);
  expect(fh_q_is_canonical(&t), "canonical negative den");
  expect_fmt(&t, "-1/2", "3/-6");
  t = q(-2, -4);
  expect_fmt(&t, "1/2", "-2/-4");
  t = q(0, -5);
  expect_fmt(&t, "0/1", "zero num");
  t = q(INT64_MIN, -1);
  expect(fh_q_is_canonical(&t), "int64 min canonical");
  expect_fmt(&t, "9223372036854775808/1", "int64 min / -1");
  t = q(INT64_MIN, INT64_MIN);
  expect_fmt(&t, "1/1", "min/min");

  FhQ a = q(1, 2);
  FhQ b = q(1, 3);
  FhQ c;
  expect(fh_q_add(&a, &b, &c) == FH_OK, "add rc");
  expect_fmt(&c, "5/6", "1/2+1/3");
  expect(fh_q_sub(&a, &b, &c) == FH_OK, "sub rc");
  expect_fmt(&c, "1/6", "1/2-1/3");
  expect(fh_q_mul(&a, &b, &c) == FH_OK, "mul rc");
  expect_fmt(&c, "1/6", "1/2*1/3");
  expect(fh_q_div(&a, &b, &c) == FH_OK, "div rc");
  expect_fmt(&c, "3/2", "1/2 / 1/3");
  FhQ zero = q(0, 1);
  expect(fh_q_div(&a, &zero, &c) == FH_REJECT_DENOM, "div zero");

  int cmp = 99;
  FhQ c13 = q(1, 3), c12 = q(1, 2), cn32 = q(-3, 2), cn12 = q(-1, 2), c24 = q(2, 4);
  expect(fh_q_cmp(&c13, &c12, &cmp) == FH_OK && cmp < 0, "1/3<1/2");
  expect(fh_q_cmp(&cn32, &cn12, &cmp) == FH_OK && cmp < 0, "neg cmp");
  expect(fh_q_cmp(&c24, &c12, &cmp) == FH_OK && cmp == 0, "value eq");

  /* Large exact values: (2^30)^2 = 2^60, (2^60)*(2^30) = 2^90. */
  FhQ p30 = q(1L << 30, 1);
  FhQ p60, p90;
  expect(fh_q_mul(&p30, &p30, &p60) == FH_OK, "2^60 rc");
  expect_fmt(&p60, "1152921504606846976/1", "2^60");
  expect(fh_q_mul(&p60, &p30, &p90) == FH_OK, "2^90 rc");
  expect_fmt(&p90, "1237940039285380274899124224/1", "2^90");
  FhQ shifted;
  expect(fh_q_from_shift(100, 0, &shifted) == FH_OK, "shift 100");
  expect_fmt(&shifted, "1267650600228229401496703205376/1", "2^100");
  FhQ half;
  expect(fh_q_from_shift(40, 0, &half) == FH_OK, "shift 40");
  expect(fh_q_div(&shifted, &half, &c) == FH_OK, "2^100/2^40");
  expect_fmt(&c, "1152921504606846976/1", "2^60 via div");

  /* Overflow must not wrap into a plausible answer. */
  FhQ big;
  expect(fh_q_from_shift(288, 0, &big) == FH_OK, "2^288");
  expect(fh_q_mul(&big, &big, &c) == FH_REJECT_OVERFLOW, "mul overflow");
  expect(fh_q_add(&big, &big, &c) == FH_OK, "2^288+2^288 fits as 2^289");
  FhQ top;
  expect(fh_q_from_shift(511, 0, &top) == FH_OK, "2^511");
  expect(fh_q_add(&top, &top, &c) == FH_REJECT_OVERFLOW, "add overflow");
  expect(fh_q_from_shift(512, 0, &top) == FH_REJECT_OVERFLOW, "shift past limbs");

  /* Round-trip identity on awkward fractions. */
  a = q(-7, 3);
  b = q(11, 5);
  expect(fh_q_add(&a, &b, &c) == FH_OK, "add id rc");
  FhQ back;
  expect(fh_q_sub(&c, &b, &back) == FH_OK, "sub id rc");
  expect(fh_q_cmp(&back, &a, &cmp) == FH_OK && cmp == 0, "(a+b)-b=a");
  expect(fh_q_mul(&a, &b, &c) == FH_OK, "mul id rc");
  expect(fh_q_div(&c, &b, &back) == FH_OK, "div id rc");
  expect(fh_q_cmp(&back, &a, &cmp) == FH_OK && cmp == 0, "(a*b)/b=a");

  /* Same inputs, same outputs. */
  char b1[64], b2[64];
  FhQ r1, r2;
  fh_q_add(&a, &b, &r1);
  fh_q_add(&a, &b, &r2);
  fh_q_format(&r1, b1, sizeof b1);
  fh_q_format(&r2, b2, sizeof b2);
  expect(strcmp(b1, b2) == 0, "deterministic arithmetic");

  FhModel model;
  fh_model_default(&model);
  /* Separated stack: heights 3,2,4 and no contacts. H = 9. */
  FhState s = state_of(0, 3, 0, 2, 2, 0, 4, 4, 1, 5);
  expect(fh_hard_valid(&s), "start hard");
  FhQ e;
  expect(fh_energy(&model, &s, &e) == FH_OK, "energy rc");
  expect_fmt(&e, "9/1", "energy 3+2+4");

  /* Contact: agent 1 moves to (0,2,0). Manhattan to agent 0 is |0|+|1|+|0| = 1. H = 9+1. */
  FhState contact = s;
  contact.x[1] = 0;
  expect(fh_energy(&model, &contact, &e) == FH_OK, "contact energy rc");
  expect_fmt(&e, "10/1", "one contact");

  FhAuth ok = auth_of(0, 0x7, 5, FH_TOKEN, 1);
  FhState down = s;
  down.y[0] = 2; /* actor 0 descends, H 8, no new contact (x still 0 vs 2) */
  FhResult result;
  memset(&result, 0x5a, sizeof result);
  uint32_t cs = checksum(&s, sizeof s);
  uint32_t cp = checksum(&down, sizeof down);
  uint32_t ca = checksum(&ok, sizeof ok);
  uint32_t cm = checksum(&model, sizeof model);
  int bit = fh_commit(&model, &s, &down, &ok, &result);
  expect(bit == 1, "descent commit true");
  expect(result.code == FH_OK, "descent code");
  expect(result.committed.generation == 6, "atomic generation bump");
  expect(result.committed.y[0] == 2, "committed y");
  expect(checksum(&s, sizeof s) == cs, "s not mutated");
  expect(checksum(&down, sizeof down) == cp, "sp not mutated");
  expect(checksum(&ok, sizeof ok) == ca, "auth not mutated");
  expect(checksum(&model, sizeof model) == cm, "model not mutated");
  expect_fmt(&result.energy_before, "9/1", "H before");
  expect_fmt(&result.energy_after, "8/1", "H after");

  FhResult again;
  int bit2 = fh_commit(&model, &s, &down, &ok, &again);
  expect(bit2 == bit && again.code == result.code &&
             again.committed.generation == result.committed.generation,
         "deterministic commit");

  FhState up = s;
  up.y[0] = 4;
  bit = fh_commit(&model, &s, &up, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_ENERGY, "energy increase rejected");
  expect(result.committed.generation == 0 && result.committed.y[0] == 0, "no partial commit");

  /* Hard violation with a much smaller soft objective must still fail hard. */
  FhState pile = state_of(0, 0, 0, 0, 0, 0, 3, 0, 0, 5);
  expect(!fh_hard_valid(&pile), "overlap invalid");
  bit = fh_commit(&model, &s, &pile, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_HARD, "hard beats soft");

  FhAuth bad = ok;
  bad.token = 1;
  bit = fh_commit(&model, &s, &down, &bad, &result);
  expect(bit == 0 && result.code == FH_REJECT_AUTH, "bad token");
  bad = ok;
  bad.allowed_mask = 0;
  bit = fh_commit(&model, &s, &down, &bad, &result);
  expect(bit == 0 && result.code == FH_REJECT_AUTH, "mask");
  bad = ok;
  bad.generation = 4;
  bit = fh_commit(&model, &s, &down, &bad, &result);
  expect(bit == 0 && result.code == FH_REJECT_AUTH, "stale generation");
  bad = ok;
  bad.actor = 1;
  bit = fh_commit(&model, &s, &down, &bad, &result);
  expect(bit == 0 && result.code == FH_REJECT_AUTH, "wrong actor");
  bad = ok;
  bad.actor = 9;
  bit = fh_commit(&model, &s, &down, &bad, &result);
  expect(bit == 0 && result.code == FH_REJECT_INDEX, "bad index");

  FhState jump = s;
  jump.y[0] = 1;
  bit = fh_commit(&model, &s, &jump, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_VERIFY, "jump of 2");
  FhState diag = s;
  diag.x[0] = 1;
  diag.z[0] = 1;
  bit = fh_commit(&model, &s, &diag, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_VERIFY, "diagonal");
  FhState two = down;
  two.y[2] = 3;
  bit = fh_commit(&model, &s, &two, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_VERIFY, "two movers");
  FhState mal = down;
  mal.generation = 9;
  bit = fh_commit(&model, &s, &mal, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_MALFORMED, "generation mismatch");

  /* Identity hold is a descent (energy unchanged). */
  bit = fh_commit(&model, &s, &s, &ok, &result);
  expect(bit == 1 && result.committed.generation == 6, "hold commits");

  /* Stir: energy may rise when descent is off. */
  FhAuth stir = ok;
  stir.descent = 0;
  bit = fh_commit(&model, &s, &up, &stir, &result);
  expect(bit == 1 && result.code == FH_OK, "stir allows ascent");

  FhState genmax = s;
  genmax.generation = UINT32_MAX;
  FhAuth amax = ok;
  amax.generation = UINT32_MAX;
  FhState holdmax = genmax;
  bit = fh_commit(&model, &genmax, &holdmax, &amax, &result);
  expect(bit == 0 && result.code == FH_REJECT_OVERFLOW, "generation overflow");

  /* Broken weight denominator cannot silently accept. */
  FhModel badm = model;
  memset(&badm.w[0], 0, sizeof badm.w[0]);
  bit = fh_commit(&badm, &s, &down, &ok, &result);
  expect(bit == 0 && result.code == FH_REJECT_DENOM, "bad weight denom");

  char conflict[64];
  expect(fh_conflict_report(&pile, conflict, sizeof conflict) == FH_REJECT_CONFLICT, "conflict code");
  expect(strcmp(conflict, "overlap 0 1") == 0, "conflict text");
  FhState oob = s;
  oob.y[2] = 8;
  expect(fh_conflict_report(&oob, conflict, sizeof conflict) == FH_REJECT_CONFLICT, "bounds code");
  expect(strcmp(conflict, "bounds 2") == 0, "bounds text");
  expect(fh_conflict_report(&s, conflict, sizeof conflict) == FH_OK, "clear conflict");

  FhCode cc = FH_OK;
  FhCert cert;
  memset(&cert, 0, sizeof cert);
  cert.kind = 1;
  cert.var_index = 0;
  cert.lo = 4;
  cert.hi = 2;
  expect(fh_cert_accept(&cert, &cc) == 1 && cc == FH_OK, "bound cert");
  cert.hi = 4;
  expect(fh_cert_accept(&cert, &cc) == 0 && cc == FH_REJECT_CERT, "weak bound");
  memset(&cert, 0, sizeof cert);
  cert.kind = 2;
  cert.n_bodies = 5;
  cert.n_cells = 4;
  expect(fh_cert_accept(&cert, &cc) == 1, "pigeon cert");
  cert.n_cells = 9;
  expect(fh_cert_accept(&cert, &cc) == 0, "not pigeon");
  cert.n_bodies = -1;
  cert.n_cells = -2;
  expect(fh_cert_accept(&cert, &cc) == 0, "negative pigeon rejected");
  memset(&cert, 0, sizeof cert);
  cert.kind = 3;
  cert.i = 0;
  cert.j = 1;
  expect(fh_cert_accept(&cert, &cc) == 1, "force overlap cert");
  cert.j = 0;
  expect(fh_cert_accept(&cert, &cc) == 0, "self overlap not a cert");
  cert.kind = 99;
  expect(fh_cert_accept(&cert, &cc) == 0, "unknown cert");

  expect(fh_solver_probe() == FH_REJECT_SOLVER, "solver probe fail-closed");
  expect(fh_commit(NULL, &s, &down, &ok, &result) == 0, "null model");

  /* Conflicting pairwise penalty: negative J would reward contact.
     Descent still refuses an increase of the true objective, and a move
     that only "improves" via a sign-flipped reading is not what we evaluate.
     Here J is negative, contact lowers H, descent may commit — the kernel
     evaluates the given J exactly. A contradictory pair of hard bounds is
     rejected by the certificate, not papered over. */
  FhModel negj = model;
  negj.J[0] = q(-1, 1);
  FhState apart = state_of(0, 1, 0, 2, 1, 0, 4, 1, 1, 1);
  FhState touch = apart;
  touch.x[1] = 1;
  FhAuth a1 = auth_of(1, 0x7, 1, FH_TOKEN, 1);
  bit = fh_commit(&negj, &apart, &touch, &a1, &result);
  expect(bit == 1, "signed J is exact, not clamped");
  expect_fmt(&result.energy_before, "3/1", "H without contact");
  expect_fmt(&result.energy_after, "2/1", "negative J lowers H");

  if (g_fail) {
    fprintf(stderr, "%d failures\n", g_fail);
    return 1;
  }
  printf("fh tests passed\n");
  return 0;
}
