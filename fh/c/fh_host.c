/* Copyright (C) 2026 AHMAD ALI PARR
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "fh.h"

#include <stdint.h>

static int last_code;

int64_t HostLastCode(void) { return last_code; }

int64_t HostCommit(int64_t x0, int64_t y0, int64_t z0, int64_t x1, int64_t y1, int64_t z1,
                   int64_t x2, int64_t y2, int64_t z2, int64_t gen, int64_t px0, int64_t py0,
                   int64_t pz0, int64_t px1, int64_t py1, int64_t pz1, int64_t px2, int64_t py2,
                   int64_t pz2, int64_t pgen, int64_t actor, int64_t mask, int64_t token,
                   int64_t descent) {
  FhModel model;
  FhState s, sp;
  FhAuth auth;
  FhResult result;
  fh_model_default(&model);
  s.x[0] = (int16_t)x0;
  s.y[0] = (int16_t)y0;
  s.z[0] = (int16_t)z0;
  s.x[1] = (int16_t)x1;
  s.y[1] = (int16_t)y1;
  s.z[1] = (int16_t)z1;
  s.x[2] = (int16_t)x2;
  s.y[2] = (int16_t)y2;
  s.z[2] = (int16_t)z2;
  s.generation = (uint32_t)gen;
  sp.x[0] = (int16_t)px0;
  sp.y[0] = (int16_t)py0;
  sp.z[0] = (int16_t)pz0;
  sp.x[1] = (int16_t)px1;
  sp.y[1] = (int16_t)py1;
  sp.z[1] = (int16_t)pz1;
  sp.x[2] = (int16_t)px2;
  sp.y[2] = (int16_t)py2;
  sp.z[2] = (int16_t)pz2;
  sp.generation = (uint32_t)pgen;
  auth.actor = (uint8_t)actor;
  auth.allowed_mask = (uint8_t)mask;
  auth.generation = (uint32_t)gen;
  auth.token = (uint32_t)token;
  auth.descent = (uint8_t)descent;
  int bit = fh_commit(&model, &s, &sp, &auth, &result);
  last_code = (int)result.code;
  return bit;
}
