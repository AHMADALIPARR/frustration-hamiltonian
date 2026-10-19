#ifndef FH_H
#define FH_H
/*
 * Frustration Hamiltonian kernel.
 *
 *   H_F(s) = Σ_i w_i V_i(s) + Σ_{i<j} J_ij C_ij(s)
 *   V_i = y_i,  C_ij = 1 iff Manhattan(i,j) = 1, else 0.
 *
 *   Commit(s,s') iff HardValid(s') ∧ Authorized(s,s') ∧ Verified(s,s')
 *   and, when descent is requested, H_F(s') ≤ H_F(s).
 *
 * Failure classification order (first match wins):
 *   MALFORMED, INDEX, HARD, AUTH, VERIFY, DENOM, OVERFLOW, ENERGY.
 * Hard rejection never looks at whether the soft objective improved.
 * Arithmetic that would exceed FH_LIMBS is rejected. It does not wrap.
 */
#include <stddef.h>
#include <stdint.h>

#define FH_N 3
#define FH_B 7
#define FH_LIMBS 16
#define FH_TOKEN 0x46525354u

typedef enum {
  FH_OK = 0,
  FH_REJECT_HARD = 1,
  FH_REJECT_AUTH = 2,
  FH_REJECT_VERIFY = 3,
  FH_REJECT_ENERGY = 4,
  FH_REJECT_OVERFLOW = 5,
  FH_REJECT_DENOM = 6,
  FH_REJECT_MALFORMED = 7,
  FH_REJECT_INDEX = 8,
  FH_REJECT_CERT = 9,
  FH_REJECT_SOLVER = 10,
  FH_REJECT_MUTATION = 11,
  FH_REJECT_CONFLICT = 12
} FhCode;

typedef struct {
  uint32_t limb[FH_LIMBS];
  uint16_t n;
  int8_t neg;
} FhBig;

typedef struct {
  FhBig num;
  FhBig den;
} FhQ;

typedef struct {
  int16_t x[FH_N];
  int16_t y[FH_N];
  int16_t z[FH_N];
  uint32_t generation;
} FhState;

typedef struct {
  uint8_t actor;
  uint8_t allowed_mask;
  uint32_t generation;
  uint32_t token;
  uint8_t descent;
} FhAuth;

typedef struct {
  FhQ w[FH_N];
  FhQ J[3];
} FhModel;

typedef struct {
  int32_t kind; /* 1 bound, 2 pigeon, 3 force-overlap */
  int32_t var_index;
  int32_t lo;
  int32_t hi;
  int32_t n_bodies;
  int32_t n_cells;
  int32_t i;
  int32_t j;
} FhCert;

typedef struct {
  FhCode code;
  FhQ energy_before;
  FhQ energy_after;
  FhState committed;
} FhResult;

int fh_q_from_i64(int64_t num, int64_t den, FhQ *out);
int fh_q_from_shift(int shift, int neg, FhQ *out);
int fh_q_normalize(FhQ *q);
int fh_q_is_canonical(const FhQ *q);
int fh_q_cmp(const FhQ *a, const FhQ *b, int *out_cmp);
int fh_q_add(const FhQ *a, const FhQ *b, FhQ *out);
int fh_q_sub(const FhQ *a, const FhQ *b, FhQ *out);
int fh_q_mul(const FhQ *a, const FhQ *b, FhQ *out);
int fh_q_div(const FhQ *a, const FhQ *b, FhQ *out);
int fh_q_format(const FhQ *q, char *buf, size_t n);

void fh_model_default(FhModel *m);

int fh_hard_valid(const FhState *s);
int fh_energy(const FhModel *m, const FhState *s, FhQ *out);
int fh_authorized(const FhState *s, const FhState *sp, const FhAuth *a);
int fh_verified(const FhState *s, const FhState *sp);
int fh_commit(const FhModel *m, const FhState *s, const FhState *sp,
              const FhAuth *a, FhResult *result);

int fh_cert_accept(const FhCert *c, FhCode *code);
int fh_conflict_report(const FhState *s, char *buf, size_t n);
int fh_solver_probe(void);

#endif
