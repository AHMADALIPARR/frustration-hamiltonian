/* Copyright (C) 2026 AHMAD ALI PARR
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
#include "fh.h"

#include <stdio.h>
#include <string.h>

static void big_zero(FhBig *a) { memset(a, 0, sizeof *a); }

static void big_trim(FhBig *a) {
  while (a->n > 0 && a->limb[a->n - 1] == 0) a->n--;
  if (a->n == 0) a->neg = 0;
}

static int big_even(const FhBig *a) { return a->n == 0 || (a->limb[0] & 1u) == 0; }

static int big_cmp_abs(const FhBig *a, const FhBig *b) {
  if (a->n != b->n) return a->n < b->n ? -1 : 1;
  for (int i = (int)a->n - 1; i >= 0; --i) {
    if (a->limb[i] != b->limb[i]) return a->limb[i] < b->limb[i] ? -1 : 1;
  }
  return 0;
}

static int big_shl1(FhBig *a) {
  uint32_t carry = 0;
  for (uint16_t i = 0; i < a->n; ++i) {
    uint32_t next = a->limb[i] >> 31;
    a->limb[i] = (a->limb[i] << 1) | carry;
    carry = next;
  }
  if (carry) {
    if (a->n >= FH_LIMBS) return FH_REJECT_OVERFLOW;
    a->limb[a->n++] = carry;
  }
  return FH_OK;
}

static void big_shr1(FhBig *a) {
  uint32_t carry = 0;
  for (int i = (int)a->n - 1; i >= 0; --i) {
    uint32_t next = a->limb[i] & 1u;
    a->limb[i] = (a->limb[i] >> 1) | (carry << 31);
    carry = next;
  }
  big_trim(a);
}

static int big_add_abs(const FhBig *a, const FhBig *b, FhBig *o) {
  FhBig r;
  big_zero(&r);
  uint64_t carry = 0;
  int n = a->n > b->n ? a->n : b->n;
  for (int i = 0; i < n; ++i) {
    uint64_t av = i < a->n ? a->limb[i] : 0;
    uint64_t bv = i < b->n ? b->limb[i] : 0;
    uint64_t s = av + bv + carry;
    r.limb[i] = (uint32_t)s;
    carry = s >> 32;
  }
  r.n = (uint16_t)n;
  if (carry) {
    if (n >= FH_LIMBS) return FH_REJECT_OVERFLOW;
    r.limb[n] = (uint32_t)carry;
    r.n = (uint16_t)(n + 1);
  }
  big_trim(&r);
  *o = r;
  return FH_OK;
}

static int big_sub_abs(const FhBig *a, const FhBig *b, FhBig *o) {
  FhBig r;
  big_zero(&r);
  uint64_t borrow = 0;
  for (int i = 0; i < a->n; ++i) {
    uint64_t av = a->limb[i];
    uint64_t bv = (uint64_t)(i < b->n ? b->limb[i] : 0) + borrow;
    if (av < bv) {
      r.limb[i] = (uint32_t)((av + (1ull << 32)) - bv);
      borrow = 1;
    } else {
      r.limb[i] = (uint32_t)(av - bv);
      borrow = 0;
    }
  }
  if (borrow) return FH_REJECT_OVERFLOW;
  r.n = a->n;
  big_trim(&r);
  *o = r;
  return FH_OK;
}

static int big_add_signed(const FhBig *a, const FhBig *b, FhBig *o) {
  if (a->n == 0) {
    *o = *b;
    return FH_OK;
  }
  if (b->n == 0) {
    *o = *a;
    return FH_OK;
  }
  if (a->neg == b->neg) {
    int rc = big_add_abs(a, b, o);
    if (rc) return rc;
    o->neg = (o->n == 0) ? 0 : a->neg;
    return FH_OK;
  }
  int cmp = big_cmp_abs(a, b);
  if (cmp == 0) {
    big_zero(o);
    return FH_OK;
  }
  int rc;
  if (cmp > 0) {
    rc = big_sub_abs(a, b, o);
    if (rc == FH_OK && o->n) o->neg = a->neg;
  } else {
    rc = big_sub_abs(b, a, o);
    if (rc == FH_OK && o->n) o->neg = b->neg;
  }
  return rc;
}

static int big_mul_abs(const FhBig *a, const FhBig *b, FhBig *o) {
  if (a->n == 0 || b->n == 0) {
    big_zero(o);
    return FH_OK;
  }
  uint32_t acc[FH_LIMBS];
  memset(acc, 0, sizeof acc);
  for (int i = 0; i < a->n; ++i) {
    uint64_t carry = 0;
    for (int j = 0; j < b->n; ++j) {
      int k = i + j;
      if (k >= FH_LIMBS) return FH_REJECT_OVERFLOW;
      uint64_t cur = (uint64_t)acc[k] + (uint64_t)a->limb[i] * b->limb[j] + carry;
      acc[k] = (uint32_t)cur;
      carry = cur >> 32;
    }
    int k = i + b->n;
    while (carry) {
      if (k >= FH_LIMBS) return FH_REJECT_OVERFLOW;
      uint64_t cur = (uint64_t)acc[k] + carry;
      acc[k] = (uint32_t)cur;
      carry = cur >> 32;
      ++k;
    }
  }
  FhBig r;
  big_zero(&r);
  r.n = FH_LIMBS;
  memcpy(r.limb, acc, sizeof acc);
  big_trim(&r);
  *o = r;
  return FH_OK;
}

static int big_mul_signed(const FhBig *a, const FhBig *b, FhBig *o) {
  int rc = big_mul_abs(a, b, o);
  if (rc) return rc;
  o->neg = (o->n == 0) ? 0 : (int8_t)(a->neg ^ b->neg);
  return FH_OK;
}

static int big_gcd(FhBig a, FhBig b, FhBig *o) {
  a.neg = 0;
  b.neg = 0;
  big_trim(&a);
  big_trim(&b);
  if (a.n == 0) {
    *o = b;
    return FH_OK;
  }
  if (b.n == 0) {
    *o = a;
    return FH_OK;
  }
  int shift = 0;
  while (big_even(&a) && big_even(&b)) {
    big_shr1(&a);
    big_shr1(&b);
    ++shift;
  }
  while (big_even(&a)) big_shr1(&a);
  while (b.n != 0) {
    while (big_even(&b)) big_shr1(&b);
    if (big_cmp_abs(&a, &b) > 0) {
      FhBig t = a;
      a = b;
      b = t;
    }
    int rc = big_sub_abs(&b, &a, &b);
    if (rc) return rc;
    b.neg = 0;
  }
  for (int i = 0; i < shift; ++i) {
    int rc = big_shl1(&a);
    if (rc) return rc;
  }
  a.neg = 0;
  *o = a;
  return FH_OK;
}

static int big_bitlen(const FhBig *a) {
  if (a->n == 0) return 0;
  uint32_t top = a->limb[a->n - 1];
  int bit = 31;
  while (bit > 0 && ((top >> bit) & 1u) == 0) --bit;
  return ((int)a->n - 1) * 32 + bit + 1;
}

static int big_getbit(const FhBig *a, int i) {
  int li = i >> 5;
  if (li < 0 || li >= a->n) return 0;
  return (a->limb[li] >> (i & 31)) & 1;
}

static int big_setbit(FhBig *a, int i) {
  int li = i >> 5;
  if (li < 0 || li >= FH_LIMBS) return FH_REJECT_OVERFLOW;
  while (a->n <= li) a->limb[a->n++] = 0;
  a->limb[li] |= 1u << (i & 31);
  return FH_OK;
}

/* Quotient and remainder. Remainder uses one extra limb so a shift cannot wrap. */
static int big_divmod(const FhBig *n, const FhBig *d, FhBig *q, FhBig *r) {
  if (d->n == 0) return FH_REJECT_DENOM;
  uint32_t rl[FH_LIMBS + 1];
  memset(rl, 0, sizeof rl);
  int rn = 0;
  FhBig qq;
  big_zero(&qq);
  int bits = big_bitlen(n);
  for (int i = bits - 1; i >= 0; --i) {
    uint32_t carry = 0;
    for (int k = 0; k < rn; ++k) {
      uint32_t next = rl[k] >> 31;
      rl[k] = (rl[k] << 1) | carry;
      carry = next;
    }
    if (carry) {
      if (rn >= FH_LIMBS + 1) return FH_REJECT_OVERFLOW;
      rl[rn++] = carry;
    }
    if (big_getbit(n, i)) {
      uint64_t c = 1;
      int k = 0;
      while (c) {
        if (k >= FH_LIMBS + 1) return FH_REJECT_OVERFLOW;
        if (k == rn) rn = k + 1;
        uint64_t cur = (uint64_t)rl[k] + c;
        rl[k] = (uint32_t)cur;
        c = cur >> 32;
        ++k;
      }
    }
    FhBig rr;
    big_zero(&rr);
    int use = rn > FH_LIMBS ? FH_LIMBS : rn;
    /* If the extra limb is set, remainder >= 2^(32*FH_LIMBS) > any divisor. */
    int ge;
    if (rn > FH_LIMBS) {
      ge = 1;
    } else {
      rr.n = (uint16_t)use;
      memcpy(rr.limb, rl, (size_t)use * sizeof(uint32_t));
      big_trim(&rr);
      ge = big_cmp_abs(&rr, d) >= 0;
    }
    if (ge) {
      if (rn > FH_LIMBS) return FH_REJECT_OVERFLOW;
      FhBig rr2;
      big_zero(&rr2);
      rr2.n = (uint16_t)rn;
      memcpy(rr2.limb, rl, (size_t)rn * sizeof(uint32_t));
      big_trim(&rr2);
      int rc = big_sub_abs(&rr2, d, &rr2);
      if (rc) return rc;
      memset(rl, 0, sizeof rl);
      memcpy(rl, rr2.limb, sizeof rr2.limb);
      rn = rr2.n;
      rc = big_setbit(&qq, i);
      if (rc) return rc;
    }
  }
  FhBig rr;
  big_zero(&rr);
  if (rn > FH_LIMBS) return FH_REJECT_OVERFLOW;
  rr.n = (uint16_t)rn;
  memcpy(rr.limb, rl, (size_t)rn * sizeof(uint32_t));
  big_trim(&rr);
  *q = qq;
  *r = rr;
  return FH_OK;
}

static int big_set_u64(FhBig *a, uint64_t v) {
  big_zero(a);
  if (v == 0) return FH_OK;
  a->limb[0] = (uint32_t)v;
  a->limb[1] = (uint32_t)(v >> 32);
  a->n = a->limb[1] ? 2 : 1;
  return FH_OK;
}

static int q_finish(FhBig num, FhBig den, FhQ *out) {
  big_trim(&num);
  big_trim(&den);
  if (den.n == 0) return FH_REJECT_DENOM;
  if (den.neg) {
    den.neg = 0;
    if (num.n) num.neg = (int8_t)(num.neg ^ 1);
  }
  if (num.n == 0) {
    FhQ z;
    memset(&z, 0, sizeof z);
    z.den.limb[0] = 1;
    z.den.n = 1;
    *out = z;
    return FH_OK;
  }
  FhBig g;
  int rc = big_gcd(num, den, &g);
  if (rc) return rc;
  FhBig nq, nr, dq, dr;
  rc = big_divmod(&num, &g, &nq, &nr);
  if (rc) return rc;
  rc = big_divmod(&den, &g, &dq, &dr);
  if (rc) return rc;
  if (nr.n != 0 || dr.n != 0 || dq.n == 0) return FH_REJECT_OVERFLOW;
  nq.neg = num.neg;
  dq.neg = 0;
  if (nq.n == 0) nq.neg = 0;
  out->num = nq;
  out->den = dq;
  return FH_OK;
}

int fh_q_from_i64(int64_t num, int64_t den, FhQ *out) {
  if (!out) return FH_REJECT_MALFORMED;
  if (den == 0) return FH_REJECT_DENOM;
  FhBig n, d;
  int neg = 0;
  if (den < 0) {
    neg ^= 1;
    if (den == INT64_MIN) {
      big_zero(&d);
      d.limb[1] = 0x80000000u;
      d.n = 2;
    } else {
      big_set_u64(&d, (uint64_t)(-den));
    }
  } else {
    big_set_u64(&d, (uint64_t)den);
  }
  if (num < 0) {
    neg ^= 1;
    if (num == INT64_MIN) {
      big_zero(&n);
      n.limb[1] = 0x80000000u;
      n.n = 2;
    } else {
      big_set_u64(&n, (uint64_t)(-num));
    }
  } else {
    big_set_u64(&n, (uint64_t)num);
  }
  n.neg = (n.n && neg) ? 1 : 0;
  d.neg = 0;
  return q_finish(n, d, out);
}

int fh_q_from_shift(int shift, int neg, FhQ *out) {
  if (!out || shift < 0) return FH_REJECT_MALFORMED;
  FhBig n;
  big_zero(&n);
  int rc = big_setbit(&n, shift);
  if (rc) return rc;
  n.neg = neg ? 1 : 0;
  FhBig d;
  big_zero(&d);
  d.limb[0] = 1;
  d.n = 1;
  return q_finish(n, d, out);
}

int fh_q_normalize(FhQ *q) {
  if (!q) return FH_REJECT_MALFORMED;
  return q_finish(q->num, q->den, q);
}

static int limbs_clean(const FhBig *a) {
  if (a->n > FH_LIMBS) return 0;
  if (a->neg != 0 && a->neg != 1) return 0;
  if (a->n == 0) return a->neg == 0;
  if (a->limb[a->n - 1] == 0) return 0;
  for (int i = a->n; i < FH_LIMBS; ++i)
    if (a->limb[i] != 0) return 0;
  return 1;
}

int fh_q_is_canonical(const FhQ *q) {
  if (!q) return 0;
  if (!limbs_clean(&q->num) || !limbs_clean(&q->den)) return 0;
  if (q->den.n == 0 || q->den.neg != 0) return 0;
  if (q->num.n == 0) {
    return q->num.neg == 0 && q->den.n == 1 && q->den.limb[0] == 1;
  }
  FhBig g;
  if (big_gcd(q->num, q->den, &g) != FH_OK) return 0;
  return g.n == 1 && g.limb[0] == 1 && g.neg == 0;
}

static int q_cross(const FhQ *a, const FhQ *b, int *cmp) {
  if (a->den.n == 0 || b->den.n == 0) return FH_REJECT_DENOM;
  FhBig ad, bc;
  int rc = big_mul_signed(&a->num, &b->den, &ad);
  if (rc) return rc;
  rc = big_mul_signed(&b->num, &a->den, &bc);
  if (rc) return rc;
  if (ad.n == 0 && bc.n == 0) {
    *cmp = 0;
    return FH_OK;
  }
  if (ad.neg != bc.neg) {
    *cmp = ad.neg ? -1 : 1;
    if (ad.n == 0) *cmp = bc.neg ? 1 : -1;
    return FH_OK;
  }
  int c = big_cmp_abs(&ad, &bc);
  *cmp = ad.neg ? -c : c;
  return FH_OK;
}

int fh_q_cmp(const FhQ *a, const FhQ *b, int *out_cmp) {
  if (!a || !b || !out_cmp) return FH_REJECT_MALFORMED;
  return q_cross(a, b, out_cmp);
}

static int q_binop(const FhQ *a, const FhQ *b, int op, FhQ *out) {
  if (!a || !b || !out) return FH_REJECT_MALFORMED;
  if (a->den.n == 0 || b->den.n == 0) return FH_REJECT_DENOM;
  FhBig n, d;
  int rc;
  if (op == 2) {
    rc = big_mul_signed(&a->num, &b->num, &n);
    if (rc) return rc;
    rc = big_mul_abs(&a->den, &b->den, &d);
    if (rc) return rc;
    d.neg = 0;
    return q_finish(n, d, out);
  }
  if (op == 3) {
    if (b->num.n == 0) return FH_REJECT_DENOM;
    rc = big_mul_signed(&a->num, &b->den, &n);
    if (rc) return rc;
    rc = big_mul_abs(&a->den, &b->num, &d);
    if (rc) return rc;
    if (b->num.neg) n.neg = (n.n == 0) ? 0 : (int8_t)(n.neg ^ 1);
    d.neg = 0;
    return q_finish(n, d, out);
  }
  /* add (op 0) or sub (op 1): a/b ± c/d = (a*d ± c*b) / (b*d) */
  FhBig ad, cb, bd;
  rc = big_mul_signed(&a->num, &b->den, &ad);
  if (rc) return rc;
  rc = big_mul_signed(&b->num, &a->den, &cb);
  if (rc) return rc;
  if (op == 1) cb.neg = (cb.n == 0) ? 0 : (int8_t)(cb.neg ^ 1);
  rc = big_add_signed(&ad, &cb, &n);
  if (rc) return rc;
  rc = big_mul_abs(&a->den, &b->den, &bd);
  if (rc) return rc;
  bd.neg = 0;
  return q_finish(n, bd, out);
}

int fh_q_add(const FhQ *a, const FhQ *b, FhQ *out) { return q_binop(a, b, 0, out); }
int fh_q_sub(const FhQ *a, const FhQ *b, FhQ *out) { return q_binop(a, b, 1, out); }
int fh_q_mul(const FhQ *a, const FhQ *b, FhQ *out) { return q_binop(a, b, 2, out); }
int fh_q_div(const FhQ *a, const FhQ *b, FhQ *out) { return q_binop(a, b, 3, out); }

static int divmod10(FhBig *a, int *digit) {
  uint64_t rem = 0;
  for (int i = (int)a->n - 1; i >= 0; --i) {
    uint64_t cur = (rem << 32) | a->limb[i];
    a->limb[i] = (uint32_t)(cur / 10);
    rem = cur % 10;
  }
  big_trim(a);
  *digit = (int)rem;
  return FH_OK;
}

int fh_q_format(const FhQ *q, char *buf, size_t n) {
  if (!q || !buf || n < 4) return FH_REJECT_MALFORMED;
  if (q->den.n == 0) return FH_REJECT_DENOM;
  char left[FH_LIMBS * 10 + 4];
  char right[FH_LIMBS * 10 + 4];
  FhBig a = q->num;
  int neg = a.neg && a.n;
  a.neg = 0;
  int ln = 0;
  if (a.n == 0) {
    left[ln++] = '0';
  } else {
    char tmp[FH_LIMBS * 10 + 2];
    int tn = 0;
    while (a.n) {
      int digit = 0;
      divmod10(&a, &digit);
      tmp[tn++] = (char)('0' + digit);
    }
    if (neg) left[ln++] = '-';
    while (tn > 0) left[ln++] = tmp[--tn];
  }
  left[ln] = 0;
  FhBig d = q->den;
  d.neg = 0;
  int rn = 0;
  char tmp[FH_LIMBS * 10 + 2];
  int tn = 0;
  if (d.n == 0) return FH_REJECT_DENOM;
  while (d.n) {
    int digit = 0;
    divmod10(&d, &digit);
    tmp[tn++] = (char)('0' + digit);
  }
  while (tn > 0) right[rn++] = tmp[--tn];
  right[rn] = 0;
  int need = snprintf(buf, n, "%s/%s", left, right);
  if (need < 0 || (size_t)need >= n) return FH_REJECT_OVERFLOW;
  return FH_OK;
}

void fh_model_default(FhModel *m) {
  memset(m, 0, sizeof *m);
  for (int i = 0; i < FH_N; ++i) {
    m->w[i].den.limb[0] = 1;
    m->w[i].den.n = 1;
    m->w[i].num.limb[0] = 1;
    m->w[i].num.n = 1;
  }
  for (int p = 0; p < 3; ++p) {
    m->J[p].den.limb[0] = 1;
    m->J[p].den.n = 1;
    m->J[p].num.limb[0] = 1;
    m->J[p].num.n = 1;
  }
}

static int in_box(int v) { return v >= 0 && v <= FH_B; }

int fh_hard_valid(const FhState *s) {
  if (!s) return 0;
  for (int i = 0; i < FH_N; ++i) {
    if (!in_box(s->x[i]) || !in_box(s->y[i]) || !in_box(s->z[i])) return 0;
  }
  for (int i = 0; i < FH_N; ++i) {
    for (int j = i + 1; j < FH_N; ++j) {
      if (s->x[i] == s->x[j] && s->y[i] == s->y[j] && s->z[i] == s->z[j]) return 0;
    }
  }
  return 1;
}

static int manhattan(const FhState *s, int i, int j) {
  int dx = s->x[i] - s->x[j];
  int dy = s->y[i] - s->y[j];
  int dz = s->z[i] - s->z[j];
  if (dx < 0) dx = -dx;
  if (dy < 0) dy = -dy;
  if (dz < 0) dz = -dz;
  return dx + dy + dz;
}

int fh_energy(const FhModel *m, const FhState *s, FhQ *out) {
  if (!m || !s || !out) return FH_REJECT_MALFORMED;
  FhQ acc;
  int rc = fh_q_from_i64(0, 1, &acc);
  if (rc) return rc;
  for (int i = 0; i < FH_N; ++i) {
    FhQ y, term;
    rc = fh_q_from_i64(s->y[i], 1, &y);
    if (rc) return rc;
    rc = fh_q_mul(&m->w[i], &y, &term);
    if (rc) return rc;
    rc = fh_q_add(&acc, &term, &acc);
    if (rc) return rc;
  }
  int pair = 0;
  for (int i = 0; i < FH_N; ++i) {
    for (int j = i + 1; j < FH_N; ++j, ++pair) {
      FhQ c, term;
      rc = fh_q_from_i64(manhattan(s, i, j) == 1 ? 1 : 0, 1, &c);
      if (rc) return rc;
      rc = fh_q_mul(&m->J[pair], &c, &term);
      if (rc) return rc;
      rc = fh_q_add(&acc, &term, &acc);
      if (rc) return rc;
    }
  }
  *out = acc;
  return FH_OK;
}

static int mover_of(const FhState *s, const FhState *sp, int *mover, int *count) {
  int c = 0;
  int who = -1;
  for (int i = 0; i < FH_N; ++i) {
    if (s->x[i] != sp->x[i] || s->y[i] != sp->y[i] || s->z[i] != sp->z[i]) {
      ++c;
      who = i;
    }
  }
  *count = c;
  *mover = who;
  return FH_OK;
}

int fh_authorized(const FhState *s, const FhState *sp, const FhAuth *a) {
  if (!s || !sp || !a) return 0;
  if (a->token != FH_TOKEN) return 0;
  if (a->actor > 2) return 0;
  if ((a->allowed_mask & (uint8_t)(1u << a->actor)) == 0) return 0;
  if (a->generation != s->generation) return 0;
  int mover = -1, count = 0;
  mover_of(s, sp, &mover, &count);
  if (count == 1 && mover != (int)a->actor) return 0;
  return 1;
}

static int delta_ok(int d) { return d >= -1 && d <= 1; }

int fh_verified(const FhState *s, const FhState *sp) {
  if (!s || !sp) return 0;
  if (sp->generation != s->generation) return 0;
  int movers = 0;
  for (int i = 0; i < FH_N; ++i) {
    int dx = (int)sp->x[i] - (int)s->x[i];
    int dy = (int)sp->y[i] - (int)s->y[i];
    int dz = (int)sp->z[i] - (int)s->z[i];
    if (!delta_ok(dx) || !delta_ok(dy) || !delta_ok(dz)) return 0;
    int l1 = (dx < 0 ? -dx : dx) + (dy < 0 ? -dy : dy) + (dz < 0 ? -dz : dz);
    if (l1 > 1) return 0;
    if (l1 == 1) ++movers;
  }
  return movers <= 1;
}

int fh_commit(const FhModel *m, const FhState *s, const FhState *sp, const FhAuth *a,
              FhResult *result) {
  FhResult local;
  memset(&local, 0, sizeof local);
  if (!m || !s || !sp || !a || !result) return 0;
  if (a->actor > 2) {
    local.code = FH_REJECT_INDEX;
    *result = local;
    return 0;
  }
  if (sp->generation != s->generation) {
    local.code = FH_REJECT_MALFORMED;
    *result = local;
    return 0;
  }
  FhQ before, after;
  int erc = fh_energy(m, s, &before);
  int erc2 = fh_energy(m, sp, &after);
  if (!fh_hard_valid(sp)) {
    local.code = FH_REJECT_HARD;
    if (erc == FH_OK && erc2 == FH_OK) {
      local.energy_before = before;
      local.energy_after = after;
    }
    *result = local;
    return 0;
  }
  if (!fh_authorized(s, sp, a)) {
    local.code = FH_REJECT_AUTH;
    *result = local;
    return 0;
  }
  if (!fh_verified(s, sp)) {
    local.code = FH_REJECT_VERIFY;
    *result = local;
    return 0;
  }
  if (erc != FH_OK) {
    local.code = (FhCode)erc;
    *result = local;
    return 0;
  }
  if (erc2 != FH_OK) {
    local.code = (FhCode)erc2;
    *result = local;
    return 0;
  }
  if (a->descent) {
    int cmp = 0;
    int rc = fh_q_cmp(&after, &before, &cmp);
    if (rc != FH_OK) {
      local.code = (FhCode)rc;
      *result = local;
      return 0;
    }
    if (cmp > 0) {
      local.code = FH_REJECT_ENERGY;
      local.energy_before = before;
      local.energy_after = after;
      *result = local;
      return 0;
    }
  }
  if (s->generation == UINT32_MAX) {
    local.code = FH_REJECT_OVERFLOW;
    *result = local;
    return 0;
  }
  local.code = FH_OK;
  local.energy_before = before;
  local.energy_after = after;
  local.committed = *sp;
  local.committed.generation = s->generation + 1;
  *result = local;
  return 1;
}

int fh_cert_accept(const FhCert *c, FhCode *code) {
  if (code) *code = FH_REJECT_CERT;
  if (!c) return 0;
  if (c->kind == 1) {
    if (c->var_index < 0 || c->var_index > 8) return 0;
    if (c->lo > c->hi) {
      if (code) *code = FH_OK;
      return 1;
    }
    return 0;
  }
  if (c->kind == 2) {
    if (c->n_bodies <= 0 || c->n_cells < 0) return 0;
    if (c->n_bodies > 1000000) return 0;
    if (c->n_bodies > c->n_cells) {
      if (code) *code = FH_OK;
      return 1;
    }
    return 0;
  }
  if (c->kind == 3) {
    if (c->i < 0 || c->j < 0 || c->i >= FH_N || c->j >= FH_N) return 0;
    if (c->i != c->j) {
      if (code) *code = FH_OK;
      return 1;
    }
    return 0;
  }
  return 0;
}

int fh_conflict_report(const FhState *s, char *buf, size_t n) {
  if (!s || !buf || n == 0) return FH_REJECT_MALFORMED;
  buf[0] = 0;
  for (int i = 0; i < FH_N; ++i) {
    if (!in_box(s->x[i]) || !in_box(s->y[i]) || !in_box(s->z[i])) {
      snprintf(buf, n, "bounds %d", i);
      return FH_REJECT_CONFLICT;
    }
  }
  for (int i = 0; i < FH_N; ++i) {
    for (int j = i + 1; j < FH_N; ++j) {
      if (s->x[i] == s->x[j] && s->y[i] == s->y[j] && s->z[i] == s->z[j]) {
        snprintf(buf, n, "overlap %d %d", i, j);
        return FH_REJECT_CONFLICT;
      }
    }
  }
  snprintf(buf, n, "clear");
  return FH_OK;
}

int fh_solver_probe(void) { return FH_REJECT_SOLVER; }
