# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later

	.file	"fh_kernel.c"
	.text
	.p2align 4
	.type	limbs_clean, @function
limbs_clean:
.LFB24:
	.cfi_startproc
	movzwl	64(%rdi), %eax
	xorl	%edx, %edx
	cmpw	$16, %ax
	ja	.L1
	movzbl	66(%rdi), %ecx
	cmpb	$1, %cl
	ja	.L1
	testw	%ax, %ax
	je	.L12
	movzwl	%ax, %esi
	leal	-1(%rsi), %ecx
	movslq	%ecx, %rcx
	movl	(%rdi,%rcx,4), %ecx
	testl	%ecx, %ecx
	je	.L1
	cmpl	$16, %esi
	jne	.L4
	jmp	.L8
	.p2align 4,,10
	.p2align 3
.L13:
	addq	$1, %rax
	cmpl	$16, %eax
	je	.L8
.L4:
	movl	(%rdi,%rax,4), %edx
	testl	%edx, %edx
	je	.L13
	xorl	%edx, %edx
.L1:
	movl	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L12:
	xorl	$1, %ecx
	movsbl	%cl, %edx
	movl	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L8:
	movl	$1, %edx
	jmp	.L1
	.cfi_endproc
.LFE24:
	.size	limbs_clean, .-limbs_clean
	.p2align 4
	.type	big_mul_abs, @function
big_mul_abs:
.LFB12:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	movq	%rdx, %rcx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$48, %rsp
	.cfi_def_cfa_offset 104
	movzwl	64(%rdi), %ebx
	testw	%bx, %bx
	je	.L15
	movzwl	64(%rsi), %eax
	testw	%ax, %ax
	jne	.L44
.L15:
	pxor	%xmm0, %xmm0
	movl	$0, 64(%rcx)
	xorl	%eax, %eax
	movups	%xmm0, (%rcx)
	movups	%xmm0, 16(%rcx)
	movups	%xmm0, 32(%rcx)
	movups	%xmm0, 48(%rcx)
	jmp	.L14
	.p2align 4,,10
	.p2align 3
.L44:
	movw	%r8w, -106(%rsp)
	pxor	%xmm0, %xmm0
	movzwl	%ax, %ebp
	movq	%rdi, %r11
	movaps	%xmm0, -104(%rsp)
	leal	-1(%rax), %r9d
	leaq	16(%rbp), %r13
	xorl	%r12d, %r12d
	leaq	-104(%rsp), %rdi
	movaps	%xmm0, -88(%rsp)
	movaps	%xmm0, -72(%rsp)
	leaq	(%rdi,%rbp,4), %r14
	movaps	%xmm0, -56(%rsp)
.L16:
	cmpq	%r13, %rbp
	je	.L23
	movl	(%r11,%r12,4), %r15d
	movq	%r12, %r8
	xorl	%eax, %eax
	jmp	.L18
	.p2align 4,,10
	.p2align 3
.L20:
	addq	$1, %r8
	cmpl	$15, %r8d
	jg	.L23
.L18:
	movl	(%rsi,%r8,4), %edx
	movl	(%rdi,%r8,4), %r10d
	imulq	%r15, %rdx
	addq	%r10, %rdx
	addq	%rax, %rdx
	movq	%rdx, %rax
	movl	%edx, (%rdi,%r8,4)
	shrq	$32, %rax
	cmpq	%r9, %r8
	jne	.L20
	testq	%rax, %rax
	je	.L26
	cmpq	$15, %rbp
	ja	.L23
	movl	$15, %edx
	subl	%ebp, %edx
	addq	%rbp, %rdx
	leaq	-100(%rsp,%rdx,4), %r8
	movq	%r14, %rdx
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L25:
	addq	$4, %rdx
	cmpq	%r8, %rdx
	je	.L23
.L24:
	movl	(%rdx), %r15d
	addq	%r15, %rax
	movl	%eax, (%rdx)
	shrq	$32, %rax
	jne	.L25
.L26:
	addq	$1, %r12
	addq	$4, %r14
	addq	$1, %rbp
	subq	$4, %rsi
	addq	$1, %r9
	cmpl	%r12d, %ebx
	jg	.L16
	movdqa	-104(%rsp), %xmm1
	movdqa	-88(%rsp), %xmm2
	xorl	%r9d, %r9d
	xorl	%edi, %edi
	movdqa	-72(%rsp), %xmm3
	movdqa	-56(%rsp), %xmm4
	movl	$16, %r10d
	movw	%r9w, 26(%rsp)
	movw	%r10w, 24(%rsp)
	movzwl	-106(%rsp), %r8d
	leaq	20(%rsp), %rax
	movl	$15, %edx
	movaps	%xmm1, -40(%rsp)
	movaps	%xmm2, -24(%rsp)
	movaps	%xmm3, -8(%rsp)
	movaps	%xmm4, 8(%rsp)
	jmp	.L27
	.p2align 4,,10
	.p2align 3
.L29:
	leal	-1(%rdx), %esi
	subq	$4, %rax
	movl	%edx, %r8d
	movl	$1, %edi
	testw	%dx, %dx
	je	.L45
	movl	%esi, %edx
.L27:
	movl	(%rax), %esi
	testl	%esi, %esi
	je	.L29
	testb	%dil, %dil
	je	.L28
	movw	%r8w, 24(%rsp)
.L28:
	movl	24(%rsp), %eax
	movdqa	-40(%rsp), %xmm5
	movdqa	-24(%rsp), %xmm6
	movdqa	-8(%rsp), %xmm7
	movdqa	8(%rsp), %xmm1
	movl	%eax, 64(%rcx)
	xorl	%eax, %eax
	movups	%xmm5, (%rcx)
	movups	%xmm6, 16(%rcx)
	movups	%xmm7, 32(%rcx)
	movups	%xmm1, 48(%rcx)
	jmp	.L14
	.p2align 4,,10
	.p2align 3
.L23:
	movl	$5, %eax
.L14:
	addq	$48, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L45:
	.cfi_restore_state
	xorl	%edi, %edi
	movw	%di, 24(%rsp)
	jmp	.L28
	.cfi_endproc
.LFE12:
	.size	big_mul_abs, .-big_mul_abs
	.p2align 4
	.type	big_shr1, @function
big_shr1:
.LFB8:
	.cfi_startproc
	movzwl	64(%rdi), %eax
	movl	%eax, %ecx
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.L47
	movslq	%edx, %rdx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L48:
	movl	(%rdi,%rdx,4), %eax
	movl	%r8d, %esi
	sall	$31, %esi
	movl	%eax, %r8d
	shrl	%eax
	orl	%esi, %eax
	andl	$1, %r8d
	movl	%eax, (%rdi,%rdx,4)
	subq	$1, %rdx
	cmpl	$-1, %edx
	jne	.L48
	movzwl	%cx, %eax
	leaq	(%rdi,%rax,4), %rax
	jmp	.L49
	.p2align 4,,10
	.p2align 3
.L51:
	subl	$1, %ecx
	subq	$4, %rax
	movw	%cx, 64(%rdi)
	testw	%cx, %cx
	je	.L47
.L49:
	movl	-4(%rax), %edx
	testl	%edx, %edx
	je	.L51
	ret
	.p2align 4,,10
	.p2align 3
.L47:
	movb	$0, 66(%rdi)
	ret
	.cfi_endproc
.LFE8:
	.size	big_shr1, .-big_shr1
	.p2align 4
	.type	q_cross, @function
q_cross:
.LFB26:
	.cfi_startproc
	cmpw	$0, 132(%rdi)
	movl	$6, %eax
	je	.L88
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rsi, %r13
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$184, %rsp
	.cfi_def_cfa_offset 240
	cmpw	$0, 132(%rsi)
	je	.L59
	leaq	16(%rsp), %rbp
	movq	%rdx, %rbx
	leaq	68(%rsi), %rsi
	movq	%rdi, %r12
	movq	%rbp, %rdx
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L59
	movzwl	80(%rsp), %r14d
	xorl	%r15d, %r15d
	testw	%r14w, %r14w
	jne	.L91
.L61:
	leaq	96(%rsp), %rcx
	leaq	68(%r12), %rsi
	movq	%r13, %rdi
	movb	%r15b, 82(%rsp)
	movq	%rcx, %rdx
	movq	%rcx, 8(%rsp)
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L59
	movzwl	160(%rsp), %edx
	testw	%dx, %dx
	je	.L62
	movzbl	66(%r13), %edi
	movq	8(%rsp), %rcx
	movzbl	134(%r12), %r8d
	movl	%edi, %esi
	xorl	%r8d, %esi
	testw	%r14w, %r14w
	movb	%sil, 162(%rsp)
	jne	.L92
	cmpb	%sil, %r15b
	jne	.L74
.L79:
	movl	$-1, %edx
.L69:
	movl	%edx, %ecx
	negl	%ecx
	testb	%r15b, %r15b
	cmovne	%ecx, %edx
.L68:
	movl	%edx, (%rbx)
.L59:
	addq	$184, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L88:
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	ret
	.p2align 4,,10
	.p2align 3
.L91:
	.cfi_def_cfa_offset 240
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movzbl	66(%r12), %r15d
	xorb	134(%r13), %r15b
	jmp	.L61
	.p2align 4,,10
	.p2align 3
.L62:
	xorl	%edx, %edx
	testw	%r14w, %r14w
	je	.L68
	testb	%r15b, %r15b
	je	.L70
.L73:
	movl	$-1, %edx
	movl	%edx, (%rbx)
	jmp	.L59
	.p2align 4,,10
	.p2align 3
.L74:
	xorl	%edx, %edx
	cmpb	%r8b, %dil
	setne	%dl
	leal	-1(%rdx,%rdx), %edx
	movl	%edx, (%rbx)
	jmp	.L59
.L94:
	movzwl	%r14w, %edx
	subl	$1, %edx
	movslq	%edx, %rdx
	jmp	.L66
	.p2align 4,,10
	.p2align 3
.L71:
	subq	$1, %rdx
	cmpl	$-1, %edx
	je	.L93
.L66:
	movl	(%rcx,%rdx,4), %edi
	cmpl	%edi, 0(%rbp,%rdx,4)
	je	.L71
	movl	$-1, %edx
	jb	.L69
.L70:
	movl	$1, %edx
	jmp	.L69
	.p2align 4,,10
	.p2align 3
.L92:
	cmpb	%sil, %r15b
	jne	.L64
	cmpw	%dx, %r14w
	je	.L94
	jnb	.L70
	jmp	.L79
	.p2align 4,,10
	.p2align 3
.L93:
	xorl	%edx, %edx
	jmp	.L69
	.p2align 4,,10
	.p2align 3
.L64:
	testb	%r15b, %r15b
	jne	.L73
	movl	$1, %edx
	movl	%edx, (%rbx)
	jmp	.L59
	.cfi_endproc
.LFE26:
	.size	q_cross, .-q_cross
	.p2align 4
	.type	big_sub_abs, @function
big_sub_abs:
.LFB10:
	.cfi_startproc
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	pxor	%xmm0, %xmm0
	movq	%rdx, %r13
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	movzwl	64(%rdi), %r10d
	movl	$0, -24(%rsp)
	movaps	%xmm0, -88(%rsp)
	movaps	%xmm0, -72(%rsp)
	movaps	%xmm0, -56(%rsp)
	movaps	%xmm0, -40(%rsp)
	testw	%r10w, %r10w
	je	.L97
	movq	%rsi, %r12
	movq	%rdi, %r8
	movl	%r10d, %esi
	xorl	%eax, %eax
	movzwl	64(%r12), %r11d
	xorl	%ecx, %ecx
	leaq	-88(%rsp), %r9
	.p2align 4,,10
	.p2align 3
.L99:
	movl	(%r8,%rax,4), %edi
	movq	%rdi, %rdx
	cmpl	%eax, %r11d
	jle	.L98
	movl	(%r12,%rax,4), %ebp
	addq	%rbp, %rcx
.L98:
	subl	%ecx, %edx
	cmpq	%rcx, %rdi
	setb	%cl
	movl	%edx, (%r9,%rax,4)
	addq	$1, %rax
	movzbl	%cl, %ecx
	cmpl	%eax, %r10d
	jg	.L99
	movl	$5, %eax
	testq	%rcx, %rcx
	jne	.L95
	movzwl	%si, %eax
	movw	%si, -24(%rsp)
	xorl	%edx, %edx
	leaq	-4(%r9,%rax,4), %rax
	jmp	.L101
	.p2align 4,,10
	.p2align 3
.L102:
	subq	$4, %rax
	movl	$1, %edx
	subw	$1, %si
	je	.L111
	movl	%esi, %ebx
.L101:
	movl	(%rax), %ecx
	testl	%ecx, %ecx
	je	.L102
	testb	%dl, %dl
	je	.L97
	movw	%bx, -24(%rsp)
.L97:
	movl	-24(%rsp), %eax
	movdqa	-88(%rsp), %xmm1
	movdqa	-72(%rsp), %xmm2
	movdqa	-56(%rsp), %xmm3
	movdqa	-40(%rsp), %xmm4
	movl	%eax, 64(%r13)
	xorl	%eax, %eax
	movups	%xmm1, 0(%r13)
	movups	%xmm2, 16(%r13)
	movups	%xmm3, 32(%r13)
	movups	%xmm4, 48(%r13)
.L95:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L111:
	.cfi_restore_state
	xorl	%esi, %esi
	movw	%si, -24(%rsp)
	jmp	.L97
	.cfi_endproc
.LFE10:
	.size	big_sub_abs, .-big_sub_abs
	.p2align 4
	.type	big_gcd, @function
big_gcd:
.LFB14:
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	movq	%rdi, %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	movzwl	112(%rsp), %ecx
	movzwl	184(%rsp), %edx
	movb	$0, 114(%rsp)
	movb	$0, 186(%rsp)
	testw	%cx, %cx
	je	.L231
	movzwl	%cx, %eax
	xorl	%esi, %esi
	leaq	44(%rsp,%rax,4), %rax
	jmp	.L116
	.p2align 4,,10
	.p2align 3
.L118:
	subq	$4, %rax
	movl	$1, %esi
	subw	$1, %cx
	je	.L234
	movl	%ecx, %r9d
.L116:
	movl	(%rax), %r10d
	testl	%r10d, %r10d
	je	.L118
	testb	%sil, %sil
	je	.L119
	movw	%r9w, 112(%rsp)
.L119:
	testw	%dx, %dx
	je	.L123
.L120:
	xorl	%esi, %esi
	jmp	.L122
	.p2align 4,,10
	.p2align 3
.L124:
	movl	$1, %esi
	subw	$1, %dx
	je	.L235
	movl	%edx, %r8d
.L122:
	movzwl	%dx, %eax
	subl	$1, %eax
	cltq
	movl	120(%rsp,%rax,4), %edi
	testl	%edi, %edi
	je	.L124
	testb	%sil, %sil
	je	.L125
	movw	%r8w, 184(%rsp)
.L125:
	testw	%cx, %cx
	je	.L117
	testw	%dx, %dx
	je	.L123
	xorl	%r13d, %r13d
	leaq	120(%rsp), %r10
.L130:
	movzwl	112(%rsp), %edi
	movzwl	184(%rsp), %ecx
	testw	%di, %di
	je	.L126
	movl	48(%rsp), %r9d
	testb	$1, %r9b
	je	.L126
.L129:
	xorl	%r10d, %r10d
	testw	%di, %di
	jne	.L236
.L136:
.L243:
	jmp	.L136
.L234:
	xorl	%r11d, %r11d
	movw	%r11w, 112(%rsp)
.L231:
	xorl	%ecx, %ecx
	testw	%dx, %dx
	jne	.L120
.L117:
	movl	184(%rsp), %eax
	movdqu	120(%rsp), %xmm0
	movdqu	136(%rsp), %xmm1
	movdqu	152(%rsp), %xmm2
	movdqu	168(%rsp), %xmm3
	movl	%eax, 64(%rbp)
	movups	%xmm0, 0(%rbp)
	movups	%xmm1, 16(%rbp)
	movups	%xmm2, 32(%rbp)
	movups	%xmm3, 48(%rbp)
.L115:
	xorl	%eax, %eax
.L112:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
.L236:
	.cfi_restore_state
	leaq	40(%rsp), %r11
	andl	$1, %r9d
	jne	.L137
.L238:
	movzwl	%di, %eax
	salq	$2, %rax
	leaq	44(%rsp,%rax), %r8
	leaq	(%r11,%rax), %rbx
	movzwl	%di, %eax
	subl	$1, %eax
	movq	%r8, %rdx
	salq	$2, %rax
	subq	%rax, %rbx
	.p2align 4,,10
	.p2align 3
.L131:
	movl	(%rdx), %eax
	movl	%r9d, %esi
	subq	$4, %rdx
	sall	$31, %esi
	movl	%eax, %r9d
	shrl	%eax
	orl	%esi, %eax
	andl	$1, %r9d
	movl	%eax, 4(%rdx)
	cmpq	%rdx, %rbx
	jne	.L131
	movl	(%r8), %edx
	testl	%edx, %edx
	jne	.L237
	.p2align 4,,10
	.p2align 3
.L134:
	subq	$4, %r8
	movl	$1, %r10d
	subw	$1, %di
	je	.L133
	movl	(%r8), %edx
	testl	%edx, %edx
	je	.L134
.L237:
	movl	48(%rsp), %r9d
	andl	$1, %r9d
	je	.L238
.L137:
	xorl	%eax, %eax
	testb	%al, %al
	je	.L138
	movb	$0, 114(%rsp)
.L138:
	testb	%r10b, %r10b
	je	.L139
	movw	%di, 112(%rsp)
.L139:
	leaq	120(%rsp), %r14
	xorl	%ebx, %ebx
	leaq	112(%rsp), %r12
	testw	%cx, %cx
	je	.L141
	.p2align 4,,10
	.p2align 3
.L140:
	movl	120(%rsp), %eax
	xorl	%r10d, %r10d
	xorl	%r9d, %r9d
	movl	%eax, %edi
	testw	%cx, %cx
	jne	.L147
.L142:
	xorl	%ecx, %ecx
	movl	$1, %r10d
	movl	%eax, %edi
	testw	%cx, %cx
	je	.L142
.L147:
	andl	$1, %edi
	jne	.L143
.L241:
	movzwl	%cx, %r8d
	movzwl	%cx, %eax
	salq	$2, %r8
	subl	$1, %eax
	leaq	-4(%r14,%r8), %rsi
	salq	$2, %rax
	addq	%r12, %r8
	subq	%rax, %r8
	movq	%rsi, %rdx
	.p2align 4,,10
	.p2align 3
.L144:
	movl	(%rdx), %eax
	movl	%edi, %r11d
	subq	$4, %rdx
	sall	$31, %r11d
	movl	%eax, %edi
	shrl	%eax
	orl	%r11d, %eax
	andl	$1, %edi
	movl	%eax, 4(%rdx)
	cmpq	%rdx, %r8
	jne	.L144
	movl	(%rsi), %eax
	testl	%eax, %eax
	jne	.L239
	.p2align 4,,10
	.p2align 3
.L146:
	subq	$4, %rsi
	movl	$1, %r9d
	subw	$1, %cx
	je	.L240
	movl	(%rsi), %eax
	testl	%eax, %eax
	je	.L146
.L239:
	movl	120(%rsp), %edi
	andl	$1, %edi
	je	.L241
.L143:
	testb	%r10b, %r10b
	je	.L149
	movb	%bl, 186(%rsp)
.L149:
	testb	%r9b, %r9b
	je	.L150
	movw	%cx, 184(%rsp)
.L150:
	movzwl	112(%rsp), %edx
	cmpw	%cx, %dx
	jne	.L233
	movzwl	%cx, %eax
	subl	$1, %eax
	cltq
	jmp	.L155
	.p2align 4,,10
	.p2align 3
.L154:
	subq	$1, %rax
	cmpl	$-1, %eax
	je	.L152
.L155:
	movl	(%r14,%rax,4), %ecx
	cmpl	%ecx, 48(%rsp,%rax,4)
	je	.L154
.L233:
	jb	.L152
	movl	184(%rsp), %eax
	movdqu	48(%rsp), %xmm3
	movw	%dx, 184(%rsp)
	movdqu	64(%rsp), %xmm2
	movdqu	80(%rsp), %xmm1
	movdqu	96(%rsp), %xmm0
	movdqu	120(%rsp), %xmm4
	movl	%eax, 112(%rsp)
	movdqu	136(%rsp), %xmm5
	movups	%xmm3, 120(%rsp)
	movdqu	152(%rsp), %xmm6
	movdqu	168(%rsp), %xmm7
	movups	%xmm4, 48(%rsp)
	movups	%xmm5, 64(%rsp)
	movups	%xmm6, 80(%rsp)
	movups	%xmm7, 96(%rsp)
	movups	%xmm2, 136(%rsp)
	movups	%xmm1, 152(%rsp)
	movups	%xmm0, 168(%rsp)
.L152:
	movq	%r14, %rdx
	leaq	48(%rsp), %rsi
	movq	%r14, %rdi
	call	big_sub_abs
	testl	%eax, %eax
	jne	.L112
	movzwl	184(%rsp), %ecx
	movb	%bl, 186(%rsp)
	testw	%cx, %cx
	jne	.L140
.L141:
	testl	%r13d, %r13d
	je	.L157
	movzwl	112(%rsp), %r8d
	xorl	%r10d, %r10d
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L158:
	testw	%r8w, %r8w
	je	.L161
	movzwl	%r8w, %eax
	leaq	48(%rsp), %rdx
	xorl	%ecx, %ecx
	leaq	48(%rsp,%rax,4), %rdi
	.p2align 4,,10
	.p2align 3
.L159:
	movl	(%rdx), %eax
	movl	%ecx, %esi
	addq	$4, %rdx
	movl	%eax, %ecx
	addl	%eax, %eax
	orl	%esi, %eax
	shrl	$31, %ecx
	movl	%eax, -4(%rdx)
	cmpq	%rdx, %rdi
	jne	.L159
	testl	%ecx, %ecx
	je	.L161
	cmpw	$15, %r8w
	ja	.L169
	movzwl	%r8w, %eax
	movl	$1, %r10d
	addl	$1, %r8d
	movl	$1, 48(%rsp,%rax,4)
.L161:
	addl	$1, %r9d
	cmpl	%r9d, %r13d
	jne	.L158
	testb	%r10b, %r10b
	je	.L157
	movw	%r8w, 112(%rsp)
.L157:
	movb	$0, 114(%rsp)
.L123:
	movdqu	48(%rsp), %xmm4
	movdqu	64(%rsp), %xmm5
	movdqu	80(%rsp), %xmm6
	movdqu	96(%rsp), %xmm7
	movl	112(%rsp), %eax
	movups	%xmm4, 0(%rbp)
	movups	%xmm5, 16(%rbp)
	movl	%eax, 64(%rbp)
	movups	%xmm6, 32(%rbp)
	movups	%xmm7, 48(%rbp)
	jmp	.L115
.L126:
	testw	%cx, %cx
	je	.L128
	testb	$1, 120(%rsp)
	jne	.L242
.L128:
	leaq	48(%rsp), %rdi
	addl	$1, %r13d
	call	big_shr1
	movq	%r10, %rdi
	call	big_shr1
	jmp	.L130
.L133:
	jmp	.L243
.L235:
	xorl	%r8d, %r8d
	movw	%r8w, 184(%rsp)
	testw	%cx, %cx
	jne	.L123
	jmp	.L117
	.p2align 4,,10
	.p2align 3
.L240:
	movl	120(%rsp), %eax
	jmp	.L142
.L169:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	movl	$5, %eax
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
.L242:
	.cfi_restore_state
	movl	48(%rsp), %r9d
	jmp	.L129
	.cfi_endproc
.LFE14:
	.size	big_gcd, .-big_gcd
	.p2align 4
	.type	big_divmod.part.0, @function
big_divmod.part.0:
.LFB50:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pxor	%xmm0, %xmm0
	movq	%rcx, %r15
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movq	%rdx, %r14
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$376, %rsp
	.cfi_def_cfa_offset 432
	movzwl	64(%rdi), %r11d
	movl	$0, 112(%rsp)
	movl	$0, 192(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 176(%rsp)
	testw	%r11w, %r11w
	je	.L335
	leal	-1(%r11), %r13d
	movq	%rdi, %r9
	movq	%rsi, %r10
	movslq	%r13d, %rax
	movl	(%rdi,%rax,4), %edx
	movl	$31, %eax
	testl	%edx, %edx
	js	.L247
	.p2align 4,,10
	.p2align 3
.L248:
	subl	$1, %eax
	je	.L247
	btl	%eax, %edx
	jnc	.L248
.L247:
	movl	%r11d, 40(%rsp)
	sall	$5, %r13d
	xorl	%ebx, %ebx
	leaq	48(%rsp), %rbp
	movq	%r9, 8(%rsp)
	addl	%eax, %r13d
	pxor	%xmm0, %xmm0
	movq	%r10, (%rsp)
	movq	%r14, 24(%rsp)
	movl	%r8d, %r14d
	movq	%r15, 32(%rsp)
	movl	%ebx, %r15d
	.p2align 4,,10
	.p2align 3
.L249:
	testl	%r15d, %r15d
	jle	.L336
	movslq	%r15d, %r10
	movq	%rbp, %rdx
	xorl	%esi, %esi
	leaq	0(%rbp,%r10,4), %rdi
	.p2align 4,,10
	.p2align 3
.L250:
	movl	(%rdx), %eax
	movl	%esi, %ecx
	addq	$4, %rdx
	movl	%eax, %esi
	addl	%eax, %eax
	orl	%ecx, %eax
	shrl	$31, %esi
	movl	%eax, -4(%rdx)
	cmpq	%rdi, %rdx
	jne	.L250
	testl	%esi, %esi
	je	.L251
	cmpl	$17, %r15d
	je	.L293
	movl	$1, 48(%rsp,%r10,4)
	addl	$1, %r15d
.L251:
	movl	%r13d, %ebx
	movl	40(%rsp), %eax
	sarl	$5, %ebx
	cmpl	%eax, %ebx
	jge	.L253
	movq	8(%rsp), %rcx
	movslq	%ebx, %rax
	movl	(%rcx,%rax,4), %eax
	btl	%r13d, %eax
	jc	.L287
.L253:
	leaq	208(%rsp), %rdi
	movaps	%xmm0, 208(%rsp)
	movl	$0, 272(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 256(%rsp)
	cmpl	$16, %r15d
	jle	.L281
.L293:
	movl	$5, %eax
.L244:
	addq	$376, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L336:
	.cfi_restore_state
	movl	%r13d, %ebx
	sarl	$5, %ebx
	cmpl	%ebx, 40(%rsp)
	jle	.L326
	movq	8(%rsp), %rdi
	movslq	%ebx, %rax
	movl	(%rdi,%rax,4), %eax
	btl	%r13d, %eax
	jc	.L287
.L326:
	movl	$0, 272(%rsp)
	pxor	%xmm1, %xmm1
	leaq	208(%rsp), %rdi
	movaps	%xmm1, 208(%rsp)
	movaps	%xmm1, 224(%rsp)
	movaps	%xmm1, 240(%rsp)
	movaps	%xmm1, 256(%rsp)
.L281:
	movw	%r15w, 272(%rsp)
	movslq	%r15d, %r10
	movq	%rbp, %rsi
	leaq	0(,%r10,4), %rdx
	movq	%r10, 16(%rsp)
	call	memcpy@PLT
	movq	16(%rsp), %r10
	pxor	%xmm0, %xmm0
	movq	%rax, %rdi
	movzwl	272(%rsp), %eax
	testw	%ax, %ax
	je	.L332
	movzwl	%ax, %edx
	xorl	%esi, %esi
	leaq	-4(%rdi,%rdx,4), %rdx
	jmp	.L261
	.p2align 4,,10
	.p2align 3
.L262:
	subq	$4, %rdx
	movl	$1, %esi
	subw	$1, %ax
	je	.L337
	movl	%eax, %r14d
.L261:
	movl	(%rdx), %r11d
	testl	%r11d, %r11d
	je	.L262
	testb	%sil, %sil
	je	.L263
	movw	%r14w, 272(%rsp)
.L263:
	movq	(%rsp), %rdx
	cmpw	64(%rdx), %ax
	je	.L338
.L334:
	jb	.L275
.L260:
	leaq	288(%rsp), %rdi
	movq	%rbp, %rsi
	leaq	0(,%r10,4), %rdx
	movl	$0, 352(%rsp)
	movaps	%xmm0, 288(%rsp)
	movw	%r15w, 352(%rsp)
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 320(%rsp)
	movaps	%xmm0, 336(%rsp)
	call	memcpy@PLT
	movq	%rax, %rdi
	movzwl	352(%rsp), %eax
	testw	%ax, %ax
	je	.L270
	movzwl	%ax, %edx
	xorl	%esi, %esi
	leaq	-4(%rdi,%rdx,4), %rdx
	jmp	.L269
	.p2align 4,,10
	.p2align 3
.L271:
	subq	$4, %rdx
	movl	$1, %esi
	subw	$1, %ax
	je	.L339
	movl	%eax, %r12d
.L269:
	movl	(%rdx), %r9d
	testl	%r9d, %r9d
	je	.L271
	testb	%sil, %sil
	je	.L268
	movw	%r12w, 352(%rsp)
.L268:
	movq	(%rsp), %rsi
	movq	%rdi, %rdx
	call	big_sub_abs
	testl	%eax, %eax
	jne	.L244
	movdqa	288(%rsp), %xmm2
	movdqa	304(%rsp), %xmm3
	movl	$0, 112(%rsp)
	movdqa	320(%rsp), %xmm4
	movdqa	336(%rsp), %xmm5
	movzwl	352(%rsp), %r15d
	movaps	%xmm2, 48(%rsp)
	movaps	%xmm3, 64(%rsp)
	movaps	%xmm4, 80(%rsp)
	movaps	%xmm5, 96(%rsp)
	cmpl	$15, %ebx
	jg	.L293
	movzwl	192(%rsp), %eax
	pxor	%xmm0, %xmm0
	cmpl	%ebx, %eax
	movl	%eax, %edx
	jg	.L273
	addl	$1, %edx
	movzwl	%dx, %edx
	.p2align 4,,10
	.p2align 3
.L274:
	cltq
	movl	$0, 128(%rsp,%rax,4)
	movl	%edx, %eax
	addl	$1, %edx
	cmpl	%eax, %ebx
	jge	.L274
	movw	%ax, 192(%rsp)
.L273:
	movslq	%ebx, %r11
	movl	$1, %eax
	movl	%r13d, %ecx
	sall	%cl, %eax
	orl	%eax, 128(%rsp,%r11,4)
.L275:
	subl	$1, %r13d
	jnb	.L249
	pxor	%xmm0, %xmm0
	movl	%r15d, %ebx
	movq	24(%rsp), %r14
	movl	$0, 352(%rsp)
	movq	32(%rsp), %r15
	movaps	%xmm0, 288(%rsp)
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 320(%rsp)
	movaps	%xmm0, 336(%rsp)
	cmpl	$16, %ebx
	jg	.L293
	movslq	%ebx, %rdx
	movl	%ebx, %r11d
	salq	$2, %rdx
	jmp	.L246
	.p2align 4,,10
	.p2align 3
.L338:
	movzwl	%ax, %eax
	subl	$1, %eax
	cltq
	jmp	.L265
	.p2align 4,,10
	.p2align 3
.L266:
	subq	$1, %rax
	cmpl	$-1, %eax
	je	.L260
.L265:
	movl	(%rdx,%rax,4), %ecx
	cmpl	%ecx, (%rdi,%rax,4)
	je	.L266
	jmp	.L334
	.p2align 4,,10
	.p2align 3
.L339:
	xorl	%r10d, %r10d
	movw	%r10w, 352(%rsp)
.L270:
	movb	$0, 354(%rsp)
	jmp	.L268
	.p2align 4,,10
	.p2align 3
.L287:
	movq	%rbp, %rsi
	xorl	%edx, %edx
	jmp	.L254
	.p2align 4,,10
	.p2align 3
.L256:
	addq	$4, %rsi
	cmpl	$17, %edx
	je	.L293
.L254:
	movl	%edx, %eax
	addl	$1, %edx
	cmpl	%eax, %r15d
	movl	(%rsi), %eax
	cmove	%edx, %r15d
	leal	1(%rax), %ecx
	addq	$1, %rax
	shrq	$32, %rax
	movl	%ecx, (%rsi)
	jne	.L256
	jmp	.L253
	.p2align 4,,10
	.p2align 3
.L337:
	xorl	%eax, %eax
	movw	%ax, 272(%rsp)
.L332:
	movq	(%rsp), %rax
	movb	$0, 274(%rsp)
	cmpw	$0, 64(%rax)
	jne	.L275
	jmp	.L260
.L335:
	movaps	%xmm0, 288(%rsp)
	xorl	%edx, %edx
	leaq	48(%rsp), %rbp
	movl	$0, 352(%rsp)
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 320(%rsp)
	movaps	%xmm0, 336(%rsp)
.L246:
	leaq	288(%rsp), %rdi
	movq	%rbp, %rsi
	movw	%r11w, 352(%rsp)
	call	memcpy@PLT
	movq	%rax, %rdi
	movzwl	352(%rsp), %eax
	testw	%ax, %ax
	je	.L285
	movzwl	%ax, %edx
	movzwl	46(%rsp), %esi
	xorl	%ecx, %ecx
	leaq	-4(%rdi,%rdx,4), %rdx
	jmp	.L284
	.p2align 4,,10
	.p2align 3
.L286:
	subq	$4, %rdx
	movl	$1, %ecx
	subw	$1, %ax
	je	.L340
	movl	%eax, %esi
.L284:
	movl	(%rdx), %edi
	testl	%edi, %edi
	je	.L286
	testb	%cl, %cl
	je	.L283
	movw	%si, 352(%rsp)
.L283:
	movdqa	128(%rsp), %xmm6
	movl	192(%rsp), %eax
	movdqa	144(%rsp), %xmm7
	movups	%xmm6, (%r14)
	movdqa	160(%rsp), %xmm6
	movups	%xmm7, 16(%r14)
	movdqa	176(%rsp), %xmm7
	movups	%xmm6, 32(%r14)
	movdqa	288(%rsp), %xmm6
	movups	%xmm7, 48(%r14)
	movdqa	304(%rsp), %xmm7
	movl	%eax, 64(%r14)
	movl	352(%rsp), %eax
	movups	%xmm6, (%r15)
	movdqa	320(%rsp), %xmm6
	movups	%xmm7, 16(%r15)
	movdqa	336(%rsp), %xmm7
	movl	%eax, 64(%r15)
	xorl	%eax, %eax
	movups	%xmm6, 32(%r15)
	movups	%xmm7, 48(%r15)
	jmp	.L244
.L340:
	xorl	%r8d, %r8d
	movw	%r8w, 352(%rsp)
.L285:
	movb	$0, 354(%rsp)
	jmp	.L283
	.cfi_endproc
.LFE50:
	.size	big_divmod.part.0, .-big_divmod.part.0
	.p2align 4
	.type	q_finish, @function
q_finish:
.LFB20:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	movq	%rdi, %rbx
	subq	$472, %rsp
	.cfi_def_cfa_offset 496
	movzwl	560(%rsp), %eax
	testw	%ax, %ax
	je	.L343
	movzwl	%ax, %edx
	xorl	%ecx, %ecx
	leaq	492(%rsp,%rdx,4), %rdx
	jmp	.L344
	.p2align 4,,10
	.p2align 3
.L345:
	subq	$4, %rdx
	movl	$1, %ecx
	subw	$1, %ax
	je	.L376
	movl	%eax, %esi
.L344:
	movl	(%rdx), %r9d
	testl	%r9d, %r9d
	je	.L345
	testb	%cl, %cl
	je	.L347
	movw	%si, 560(%rsp)
	jmp	.L347
	.p2align 4,,10
	.p2align 3
.L376:
	xorl	%r10d, %r10d
	movw	%r10w, 560(%rsp)
.L343:
	movb	$0, 562(%rsp)
	xorl	%eax, %eax
.L347:
	movzwl	632(%rsp), %edx
	testw	%dx, %dx
	je	.L351
	movzwl	%dx, %ecx
	xorl	%esi, %esi
	leaq	564(%rsp,%rcx,4), %rcx
	jmp	.L350
	.p2align 4,,10
	.p2align 3
.L352:
	subq	$4, %rcx
	movl	$1, %esi
	subw	$1, %dx
	je	.L351
	movl	%edx, %r8d
.L350:
	movl	(%rcx), %edi
	testl	%edi, %edi
	je	.L352
	testb	%sil, %sil
	je	.L353
	movw	%r8w, 632(%rsp)
.L353:
	cmpb	$0, 634(%rsp)
	je	.L377
	movb	$0, 634(%rsp)
	testw	%ax, %ax
	je	.L356
	xorb	$1, 562(%rsp)
	jmp	.L355
	.p2align 4,,10
	.p2align 3
.L351:
	movl	$6, %eax
.L341:
	addq	$472, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L356:
	.cfi_restore_state
	leaq	320(%rsp), %rdx
	xorl	%eax, %eax
	pxor	%xmm0, %xmm0
	movl	$17, %ecx
	movq	%rdx, %rdi
	movups	%xmm0, (%rbx)
	rep stosq
	movl	$1, %eax
	movups	%xmm0, 16(%rbx)
	movl	$1, 388(%rsp)
	movdqa	400(%rsp), %xmm3
	movups	%xmm0, 32(%rbx)
	movdqa	384(%rsp), %xmm2
	movdqa	416(%rsp), %xmm4
	movw	%ax, 452(%rsp)
	movdqa	432(%rsp), %xmm5
	movq	448(%rsp), %rax
	movups	%xmm0, 48(%rbx)
	movups	%xmm2, 64(%rbx)
	movq	%rax, 128(%rbx)
	xorl	%eax, %eax
	movups	%xmm3, 80(%rbx)
	movups	%xmm4, 96(%rbx)
	movups	%xmm5, 112(%rbx)
.L378:
	addq	$472, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L377:
	.cfi_restore_state
	testw	%ax, %ax
	je	.L356
.L355:
	movq	%rsp, %rbp
	subq	$144, %rsp
	.cfi_def_cfa_offset 640
	movl	776(%rsp), %eax
	movq	%rbp, %rdi
	movdqu	712(%rsp), %xmm1
	movdqu	728(%rsp), %xmm2
	movdqu	744(%rsp), %xmm3
	movdqu	760(%rsp), %xmm4
	movl	%eax, 136(%rsp)
	movl	704(%rsp), %eax
	movups	%xmm1, 72(%rsp)
	movdqu	640(%rsp), %xmm5
	movdqu	656(%rsp), %xmm6
	movups	%xmm2, 88(%rsp)
	movdqu	672(%rsp), %xmm7
	movdqu	688(%rsp), %xmm1
	movl	%eax, 64(%rsp)
	movups	%xmm3, 104(%rsp)
	movups	%xmm4, 120(%rsp)
	movups	%xmm5, (%rsp)
	movups	%xmm6, 16(%rsp)
	movups	%xmm7, 32(%rsp)
	movups	%xmm1, 48(%rsp)
	call	big_gcd
	movq	%rbp, %rsp
	.cfi_def_cfa_offset 496
	testl	%eax, %eax
	jne	.L341
	cmpw	$0, 64(%rsp)
	je	.L351
	leaq	160(%rsp), %rcx
	leaq	80(%rsp), %rdx
	movq	%rbp, %rsi
	leaq	496(%rsp), %rdi
	call	big_divmod.part.0
	testl	%eax, %eax
	jne	.L341
	leaq	320(%rsp), %rcx
	leaq	240(%rsp), %rdx
	movq	%rbp, %rsi
	leaq	568(%rsp), %rdi
	call	big_divmod.part.0
	testl	%eax, %eax
	jne	.L341
	movzwl	224(%rsp), %edx
	orw	384(%rsp), %dx
	movl	$5, %eax
	jne	.L341
	cmpw	$0, 304(%rsp)
	je	.L341
	movdqa	80(%rsp), %xmm6
	movdqa	96(%rsp), %xmm7
	xorl	%edx, %edx
	movb	$0, 306(%rsp)
	movzbl	562(%rsp), %eax
	cmpw	$0, 144(%rsp)
	movups	%xmm6, (%rbx)
	movdqa	112(%rsp), %xmm6
	cmove	%edx, %eax
	movups	%xmm7, 16(%rbx)
	movdqa	128(%rsp), %xmm7
	movups	%xmm6, 32(%rbx)
	movdqa	240(%rsp), %xmm6
	movb	%al, 146(%rsp)
	movl	144(%rsp), %eax
	movups	%xmm7, 48(%rbx)
	movdqa	256(%rsp), %xmm7
	movl	%eax, 64(%rbx)
	movl	304(%rsp), %eax
	movups	%xmm6, 68(%rbx)
	movdqa	272(%rsp), %xmm6
	movups	%xmm7, 84(%rbx)
	movdqa	288(%rsp), %xmm7
	movl	%eax, 132(%rbx)
	xorl	%eax, %eax
	movups	%xmm6, 100(%rbx)
	movups	%xmm7, 116(%rbx)
	jmp	.L378
	.cfi_endproc
.LFE20:
	.size	q_finish, .-q_finish
	.p2align 4
	.type	q_binop.part.0, @function
q_binop.part.0:
.LFB51:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	movq	%rcx, %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	movq	%rdi, %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rsi, %rbx
	subq	$360, %rsp
	.cfi_def_cfa_offset 416
	cmpl	$2, %edx
	je	.L443
	movl	%edx, %r14d
	cmpl	$3, %edx
	jne	.L383
	cmpw	$0, 64(%rsi)
	movl	$6, %eax
	je	.L379
	leaq	32(%rsp), %rdx
	leaq	68(%rsi), %rsi
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	movzwl	96(%rsp), %r14d
	xorl	%r13d, %r13d
	testw	%r14w, %r14w
	je	.L384
	movzbl	66(%rbp), %r13d
	xorb	134(%rbx), %r13b
.L384:
	leaq	272(%rsp), %rdx
	leaq	68(%rbp), %rdi
	movq	%rbx, %rsi
	movb	%r13b, 98(%rsp)
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	cmpb	$0, 66(%rbx)
	jne	.L444
.L385:
	movb	$0, 338(%rsp)
	subq	$144, %rsp
	.cfi_def_cfa_offset 560
	movdqa	416(%rsp), %xmm1
	movl	480(%rsp), %eax
	movdqa	432(%rsp), %xmm2
	movdqa	448(%rsp), %xmm3
	movdqa	464(%rsp), %xmm4
	movl	%eax, 136(%rsp)
	movdqa	176(%rsp), %xmm5
	movups	%xmm1, 72(%rsp)
	movdqa	192(%rsp), %xmm6
	movdqa	208(%rsp), %xmm7
	movups	%xmm2, 88(%rsp)
	movdqa	224(%rsp), %xmm0
	movups	%xmm3, 104(%rsp)
	movups	%xmm4, 120(%rsp)
	movups	%xmm5, (%rsp)
	movups	%xmm6, 16(%rsp)
	movups	%xmm7, 32(%rsp)
	movups	%xmm0, 48(%rsp)
.L442:
	movl	240(%rsp), %eax
	movq	%r12, %rdi
	movl	%eax, 64(%rsp)
	call	q_finish
	addq	$144, %rsp
	.cfi_def_cfa_offset 416
.L379:
	addq	$360, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L383:
	.cfi_restore_state
	leaq	68(%rsi), %rax
	leaq	112(%rsp), %r13
	movq	%r13, %rdx
	movq	%rax, %rsi
	movq	%rax, (%rsp)
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	movzwl	176(%rsp), %r15d
	xorl	%r9d, %r9d
	testw	%r15w, %r15w
	je	.L387
	movzbl	66(%rbp), %r9d
	xorb	134(%rbx), %r9b
.L387:
	leaq	192(%rsp), %r10
	leaq	68(%rbp), %rsi
	movq	%rbx, %rdi
	movb	%r9b, 178(%rsp)
	movq	%r10, %rdx
	movb	%r9b, 29(%rsp)
	movq	%rsi, 16(%rsp)
	movq	%r10, 8(%rsp)
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	movzwl	256(%rsp), %esi
	testw	%si, %si
	je	.L388
	movzbl	66(%rbx), %ebx
	xorb	134(%rbp), %bl
	movl	%ebx, %eax
	movq	8(%rsp), %r10
	movzbl	29(%rsp), %r9d
	xorl	$1, %eax
	cmpl	$1, %r14d
	cmove	%eax, %ebx
	testw	%r15w, %r15w
	movb	%bl, 258(%rsp)
	je	.L391
	cmpb	%bl, %r9b
	je	.L445
	cmpw	%si, %r15w
	jne	.L440
	movzwl	%r15w, %eax
	subl	$1, %eax
	cltq
	jmp	.L409
	.p2align 4,,10
	.p2align 3
.L408:
	subq	$1, %rax
	cmpl	$-1, %eax
	je	.L446
.L409:
	movl	(%r10,%rax,4), %ecx
	cmpl	%ecx, 0(%r13,%rax,4)
	je	.L408
.L440:
	jnb	.L447
	leaq	32(%rsp), %rdx
	movq	%r13, %rsi
	movq	%r10, %rdi
	call	big_sub_abs
	testl	%eax, %eax
	jne	.L379
	cmpw	$0, 96(%rsp)
	leaq	272(%rsp), %r8
	je	.L394
	movb	%bl, 98(%rsp)
	jmp	.L394
	.p2align 4,,10
	.p2align 3
.L443:
	leaq	32(%rsp), %rdx
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	cmpw	$0, 96(%rsp)
	je	.L382
	movzbl	66(%rbp), %eax
	xorb	66(%rbx), %al
.L382:
	leaq	272(%rsp), %rdx
	leaq	68(%rbx), %rsi
	movb	%al, 98(%rsp)
	leaq	68(%rbp), %rdi
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	movb	$0, 338(%rsp)
	subq	$144, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 560
	movdqa	416(%rsp), %xmm5
	movl	480(%rsp), %eax
	movdqa	432(%rsp), %xmm6
	movdqa	448(%rsp), %xmm7
	movdqa	208(%rsp), %xmm1
	movups	%xmm5, 72(%rsp)
	movdqa	224(%rsp), %xmm2
	movdqa	464(%rsp), %xmm5
	movups	%xmm6, 88(%rsp)
	movdqa	176(%rsp), %xmm6
	movups	%xmm7, 104(%rsp)
	movdqa	192(%rsp), %xmm7
	movl	%eax, 136(%rsp)
	movups	%xmm5, 120(%rsp)
	movups	%xmm6, (%rsp)
	movups	%xmm7, 16(%rsp)
	movups	%xmm1, 32(%rsp)
	movups	%xmm2, 48(%rsp)
	jmp	.L442
	.p2align 4,,10
	.p2align 3
.L388:
	.cfi_restore_state
	movb	$0, 258(%rsp)
	testw	%r15w, %r15w
	je	.L391
	movl	176(%rsp), %eax
	movdqa	112(%rsp), %xmm1
	leaq	272(%rsp), %r8
	movdqa	128(%rsp), %xmm2
	movdqa	144(%rsp), %xmm0
	movdqa	160(%rsp), %xmm5
	movl	%eax, 96(%rsp)
	movaps	%xmm1, 32(%rsp)
	movaps	%xmm2, 48(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm5, 80(%rsp)
.L394:
	movq	(%rsp), %rsi
	movq	16(%rsp), %rdi
	movq	%r8, %rdx
	call	big_mul_abs
	testl	%eax, %eax
	jne	.L379
	movb	$0, 338(%rsp)
	subq	$144, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 560
	movdqa	416(%rsp), %xmm3
	movl	480(%rsp), %eax
	movdqa	432(%rsp), %xmm4
	movdqa	448(%rsp), %xmm0
	movdqa	464(%rsp), %xmm5
	movups	%xmm3, 72(%rsp)
	movdqa	176(%rsp), %xmm6
	movdqa	192(%rsp), %xmm7
	movups	%xmm4, 88(%rsp)
	movdqa	208(%rsp), %xmm3
	movdqa	224(%rsp), %xmm4
	movl	%eax, 136(%rsp)
	movups	%xmm0, 104(%rsp)
	movups	%xmm5, 120(%rsp)
	movups	%xmm6, (%rsp)
	movups	%xmm7, 16(%rsp)
	movups	%xmm3, 32(%rsp)
	movups	%xmm4, 48(%rsp)
	jmp	.L442
	.p2align 4,,10
	.p2align 3
.L444:
	.cfi_restore_state
	xorl	$1, %r13d
	testw	%r14w, %r14w
	cmove	%eax, %r13d
	movb	%r13b, 98(%rsp)
	jmp	.L385
	.p2align 4,,10
	.p2align 3
.L391:
	movdqa	192(%rsp), %xmm1
	movl	256(%rsp), %eax
	leaq	272(%rsp), %r8
	movdqa	208(%rsp), %xmm2
	movdqa	224(%rsp), %xmm3
	movdqa	240(%rsp), %xmm4
	movl	%eax, 96(%rsp)
	movaps	%xmm1, 32(%rsp)
	movaps	%xmm2, 48(%rsp)
	movaps	%xmm3, 64(%rsp)
	movaps	%xmm4, 80(%rsp)
	jmp	.L394
	.p2align 4,,10
	.p2align 3
.L445:
	cmpw	%si, %r15w
	movl	%esi, %edi
	pxor	%xmm0, %xmm0
	movzwl	%r15w, %ecx
	cmovnb	%r15d, %edi
	movaps	%xmm0, 272(%rsp)
	xorl	%eax, %eax
	xorl	%edx, %edx
	movaps	%xmm0, 288(%rsp)
	leaq	272(%rsp), %r8
	movl	$0, 336(%rsp)
	movzwl	%di, %r11d
	movaps	%xmm0, 304(%rsp)
	movaps	%xmm0, 320(%rsp)
	.p2align 4,,10
	.p2align 3
.L398:
	movl	%eax, %r9d
	cmpl	%ecx, %eax
	jge	.L396
	movl	0(%r13,%rax,4), %ebp
	addq	%rbp, %rdx
.L396:
	cmpl	%r9d, %esi
	jle	.L397
	movl	(%r10,%rax,4), %r9d
	addq	%r9, %rdx
.L397:
	movl	%edx, (%r8,%rax,4)
	addq	$1, %rax
	shrq	$32, %rdx
	cmpl	%eax, %r11d
	jg	.L398
	movw	%di, 336(%rsp)
	testq	%rdx, %rdx
	je	.L399
	cmpw	$16, %di
	je	.L400
	movl	$1, 272(%rsp,%r11,4)
	addl	$1, %edi
	movw	%di, 336(%rsp)
.L399:
	movzwl	%di, %eax
	movzwl	30(%rsp), %ecx
	xorl	%edx, %edx
	leaq	-4(%r8,%rax,4), %rax
	jmp	.L401
	.p2align 4,,10
	.p2align 3
.L403:
	subq	$4, %rax
	movl	$1, %edx
	subw	$1, %di
	je	.L448
	movl	%edi, %ecx
.L401:
	movl	(%rax), %esi
	testl	%esi, %esi
	je	.L403
	testb	%dl, %dl
	je	.L402
	movw	%cx, 336(%rsp)
.L402:
	movdqa	272(%rsp), %xmm6
	movl	336(%rsp), %eax
	movdqa	288(%rsp), %xmm7
	movdqa	304(%rsp), %xmm1
	movdqa	320(%rsp), %xmm2
	movl	%eax, 96(%rsp)
	testw	%ax, %ax
	movl	$0, %eax
	cmove	%eax, %ebx
	movaps	%xmm6, 32(%rsp)
	movaps	%xmm7, 48(%rsp)
	movb	%bl, 98(%rsp)
	movaps	%xmm1, 64(%rsp)
	movaps	%xmm2, 80(%rsp)
	jmp	.L394
	.p2align 4,,10
	.p2align 3
.L447:
	leaq	32(%rsp), %rdx
	movq	%r10, %rsi
	movq	%r13, %rdi
	movb	%r9b, 8(%rsp)
	call	big_sub_abs
	testl	%eax, %eax
	jne	.L379
	cmpw	$0, 96(%rsp)
	movzbl	8(%rsp), %r9d
	je	.L441
	movb	%r9b, 98(%rsp)
.L441:
	leaq	272(%rsp), %r8
	jmp	.L394
	.p2align 4,,10
	.p2align 3
.L446:
	pxor	%xmm0, %xmm0
	movl	$0, 96(%rsp)
	leaq	272(%rsp), %r8
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 80(%rsp)
	jmp	.L394
.L400:
	movl	$5, %eax
	jmp	.L379
.L448:
	xorl	%edi, %edi
	movw	%di, 336(%rsp)
	jmp	.L402
	.cfi_endproc
.LFE51:
	.size	q_binop.part.0, .-q_binop.part.0
	.p2align 4
	.type	fh_q_from_i64.part.0, @function
fh_q_from_i64.part.0:
.LFB52:
	.cfi_startproc
	movq	%rdi, %rax
	subq	$168, %rsp
	.cfi_def_cfa_offset 176
	movq	%rdx, %rdi
	testq	%rsi, %rsi
	jns	.L450
	movabsq	$-9223372036854775808, %rdx
	cmpq	%rdx, %rsi
	je	.L468
	negq	%rsi
	pxor	%xmm0, %xmm0
	movl	$1, %edx
	movl	$1, %ecx
	movl	%esi, 80(%rsp)
	shrq	$32, %rsi
	cmpq	$1, %rsi
	movups	%xmm0, 120(%rsp)
	movl	%esi, %r8d
	movups	%xmm0, 88(%rsp)
	sbbw	$-1, %dx
	movups	%xmm0, 104(%rsp)
	movups	%xmm0, 132(%rsp)
.L452:
	movl	%r8d, 84(%rsp)
	movw	%dx, 144(%rsp)
	testq	%rax, %rax
	jns	.L455
	movabsq	$-9223372036854775808, %rdx
	xorl	$1, %ecx
	cmpq	%rdx, %rax
	je	.L469
	pxor	%xmm0, %xmm0
	negq	%rax
	movups	%xmm0, 40(%rsp)
	movups	%xmm0, 8(%rsp)
	movups	%xmm0, 24(%rsp)
	movups	%xmm0, 52(%rsp)
.L467:
	movq	%rax, (%rsp)
	shrq	$32, %rax
	movl	%ecx, %edx
	setne	%al
	movzbl	%al, %eax
	addl	$1, %eax
	movw	%ax, 64(%rsp)
.L457:
	movb	%dl, 66(%rsp)
	subq	$144, %rsp
	.cfi_def_cfa_offset 320
	movb	$0, 290(%rsp)
	movl	288(%rsp), %eax
	movdqa	224(%rsp), %xmm1
	movdqa	240(%rsp), %xmm2
	movdqa	256(%rsp), %xmm3
	movl	%eax, 136(%rsp)
	movdqa	272(%rsp), %xmm4
	movl	208(%rsp), %eax
	movups	%xmm1, 72(%rsp)
	movdqa	144(%rsp), %xmm5
	movups	%xmm2, 88(%rsp)
	movdqa	160(%rsp), %xmm6
	movdqa	176(%rsp), %xmm7
	movl	%eax, 64(%rsp)
	movdqa	192(%rsp), %xmm1
	movups	%xmm3, 104(%rsp)
	movups	%xmm4, 120(%rsp)
	movups	%xmm5, (%rsp)
	movups	%xmm6, 16(%rsp)
	movups	%xmm7, 32(%rsp)
	movups	%xmm1, 48(%rsp)
	call	q_finish
	addq	$312, %rsp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L450:
	.cfi_def_cfa_offset 176
	movl	%esi, 80(%rsp)
	shrq	$32, %rsi
	pxor	%xmm0, %xmm0
	movl	$1, %edx
	cmpq	$1, %rsi
	movups	%xmm0, 120(%rsp)
	movl	%esi, %r8d
	sbbw	$-1, %dx
	movups	%xmm0, 88(%rsp)
	xorl	%ecx, %ecx
	movups	%xmm0, 104(%rsp)
	movups	%xmm0, 132(%rsp)
	jmp	.L452
	.p2align 4,,10
	.p2align 3
.L455:
	pxor	%xmm0, %xmm0
	movl	$0, 64(%rsp)
	movl	$0, %edx
	movaps	%xmm0, (%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 48(%rsp)
	jne	.L467
	jmp	.L457
	.p2align 4,,10
	.p2align 3
.L468:
	pxor	%xmm0, %xmm0
	movl	$-2147483648, %r8d
	movl	$2, %edx
	movl	$0, 144(%rsp)
	movaps	%xmm0, 80(%rsp)
	movl	$1, %ecx
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 128(%rsp)
	jmp	.L452
	.p2align 4,,10
	.p2align 3
.L469:
	pxor	%xmm0, %xmm0
	movl	$2, %eax
	movl	$0, 64(%rsp)
	movl	%ecx, %edx
	movaps	%xmm0, (%rsp)
	movw	%ax, 64(%rsp)
	movl	$-2147483648, 4(%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 48(%rsp)
	jmp	.L457
	.cfi_endproc
.LFE52:
	.size	fh_q_from_i64.part.0, .-fh_q_from_i64.part.0
	.p2align 4
	.type	fh_energy.part.0, @function
fh_energy.part.0:
.LFB53:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	movq	%rdi, %r14
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rdx, %r13
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rsi, %rbx
	movl	$1, %esi
	subq	$504, %rsp
	.cfi_def_cfa_offset 560
	movq	%rdi, 24(%rsp)
	leaq	64(%rsp), %rdx
	xorl	%edi, %edi
	movq	%rdx, 16(%rsp)
	call	fh_q_from_i64.part.0
	testl	%eax, %eax
	jne	.L470
	leaq	208(%rsp), %r15
	leaq	408(%r14), %r12
	leaq	352(%rsp), %rax
	movq	%r15, 8(%rsp)
	leaq	6(%rbx), %rbp
	movq	%rax, (%rsp)
	movq	%r12, %rax
	movq	%r14, %r12
	movq	%rax, %r14
.L475:
	movswq	0(%rbp), %rdi
	movq	%r15, %rdx
	movl	$1, %esi
	call	fh_q_from_i64.part.0
	testl	%eax, %eax
	jne	.L470
	testq	%r12, %r12
	je	.L485
	cmpw	$0, 132(%r12)
	je	.L483
	cmpw	$0, 340(%rsp)
	je	.L483
	movq	(%rsp), %rcx
	movl	$2, %edx
	movq	%r15, %rsi
	movq	%r12, %rdi
	call	q_binop.part.0
	testl	%eax, %eax
	jne	.L470
	cmpw	$0, 196(%rsp)
	je	.L483
	cmpw	$0, 484(%rsp)
	je	.L483
	movq	16(%rsp), %rdi
	movq	(%rsp), %rsi
	xorl	%edx, %edx
	movq	%rdi, %rcx
	call	q_binop.part.0
	testl	%eax, %eax
	jne	.L470
	addq	$136, %r12
	addq	$2, %rbp
	cmpq	%r14, %r12
	jne	.L475
	movq	%r13, 56(%rsp)
	xorl	%ecx, %ecx
	xorl	%edx, %edx
.L476:
	cmpq	$2, %rdx
	je	.L477
	movslq	%ecx, %rsi
	leaq	1(%rdx), %rdi
	movl	%ecx, 44(%rsp)
	movswl	(%rbx,%rdx,2), %r14d
	movq	%rsi, %rax
	movq	%rdi, 32(%rsp)
	movq	%rdi, %r15
	movswl	6(%rbx,%rdx,2), %r13d
	salq	$4, %rax
	movq	%rdx, 48(%rsp)
	movswl	12(%rbx,%rdx,2), %r12d
	addq	%rsi, %rax
	movq	24(%rsp), %rsi
	leaq	408(%rsi,%rax,8), %rbp
	jmp	.L484
	.p2align 4,,10
	.p2align 3
.L482:
	cmpw	$0, 340(%rsp)
	je	.L483
	movq	(%rsp), %rcx
	movq	8(%rsp), %rsi
	movl	$2, %edx
	movq	%rbp, %rdi
	call	q_binop.part.0
	testl	%eax, %eax
	jne	.L470
	cmpw	$0, 196(%rsp)
	je	.L483
	cmpw	$0, 484(%rsp)
	je	.L483
	movq	16(%rsp), %rdi
	movq	(%rsp), %rsi
	xorl	%edx, %edx
	movq	%rdi, %rcx
	call	q_binop.part.0
	testl	%eax, %eax
	jne	.L470
	leaq	1(%r15), %rax
	addq	$136, %rbp
	cmpl	$2, %r15d
	je	.L495
	movq	%rax, %r15
.L484:
	movswl	(%rbx,%r15,2), %ecx
	movswl	6(%rbx,%r15,2), %edx
	movl	%r14d, %eax
	movswl	12(%rbx,%r15,2), %esi
	movl	%ecx, %edi
	subl	%r14d, %edi
	subl	%ecx, %eax
	movl	%r13d, %ecx
	cmovs	%edi, %eax
	movl	%edx, %edi
	subl	%r13d, %edi
	subl	%edx, %ecx
	movl	%r12d, %edx
	cmovs	%edi, %ecx
	movl	%esi, %edi
	subl	%r12d, %edi
	subl	%esi, %edx
	movl	$1, %esi
	cmovs	%edi, %edx
	addl	%ecx, %eax
	xorl	%edi, %edi
	addl	%edx, %eax
	movq	8(%rsp), %rdx
	cmpl	$1, %eax
	sete	%dil
	call	fh_q_from_i64.part.0
	testl	%eax, %eax
	jne	.L470
	cmpw	$0, 132(%rbp)
	jne	.L482
.L483:
	movl	$6, %eax
.L470:
	addq	$504, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L485:
	.cfi_restore_state
	movl	$7, %eax
	jmp	.L470
.L477:
	movq	56(%rsp), %r13
	movq	192(%rsp), %rax
	movdqa	64(%rsp), %xmm0
	movdqa	80(%rsp), %xmm1
	movdqa	96(%rsp), %xmm2
	movdqa	112(%rsp), %xmm3
	movq	%rax, 128(%r13)
	xorl	%eax, %eax
	movdqa	128(%rsp), %xmm4
	movups	%xmm0, 0(%r13)
	movdqa	144(%rsp), %xmm5
	movdqa	160(%rsp), %xmm6
	movups	%xmm1, 16(%r13)
	movdqa	176(%rsp), %xmm7
	movups	%xmm2, 32(%r13)
	movups	%xmm3, 48(%r13)
	movups	%xmm4, 64(%r13)
	movups	%xmm5, 80(%r13)
	movups	%xmm6, 96(%r13)
	movups	%xmm7, 112(%r13)
	jmp	.L470
	.p2align 4,,10
	.p2align 3
.L495:
	movq	48(%rsp), %rdx
	movl	44(%rsp), %ecx
	movq	32(%rsp), %rdi
	subl	%edx, %ecx
	addl	%r15d, %ecx
	movq	%rdi, %rdx
	jmp	.L476
	.cfi_endproc
.LFE53:
	.size	fh_energy.part.0, .-fh_energy.part.0
	.p2align 4
	.globl	fh_q_from_i64
	.type	fh_q_from_i64, @function
fh_q_from_i64:
.LFB21:
	.cfi_startproc
	testq	%rdx, %rdx
	je	.L498
	testq	%rsi, %rsi
	je	.L499
	jmp	fh_q_from_i64.part.0
	.p2align 4,,10
	.p2align 3
.L499:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L498:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE21:
	.size	fh_q_from_i64, .-fh_q_from_i64
	.p2align 4
	.globl	fh_q_from_shift
	.type	fh_q_from_shift, @function
fh_q_from_shift:
.LFB22:
	.cfi_startproc
	testq	%rdx, %rdx
	je	.L506
	movl	%edi, %r8d
	testl	%edi, %edi
	js	.L506
	subq	$168, %rsp
	.cfi_def_cfa_offset 176
	pxor	%xmm0, %xmm0
	movl	%r8d, %r9d
	movl	$5, %eax
	movl	$0, 64(%rsp)
	movq	%rsp, %rdi
	sarl	$5, %r9d
	movaps	%xmm0, (%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 48(%rsp)
	cmpl	$511, %r8d
	jg	.L500
	movl	%esi, %r10d
	leal	1(%r9), %esi
	movslq	%esi, %rsi
	salq	$2, %rsi
	cmpl	$8, %esi
	jnb	.L515
	andl	$4, %esi
	jne	.L516
.L505:
	leal	1(%r9), %eax
	movl	%r8d, %ecx
	movslq	%r9d, %r9
	movq	%rdx, %rdi
	movw	%ax, 64(%rsp)
	movl	$1, %eax
	pxor	%xmm0, %xmm0
	sall	%cl, %eax
	orl	%eax, (%rsp,%r9,4)
	testl	%r10d, %r10d
	movl	$1, %eax
	movups	%xmm0, 132(%rsp)
	movl	$1, 80(%rsp)
	movw	%ax, 144(%rsp)
	movups	%xmm0, 84(%rsp)
	movups	%xmm0, 100(%rsp)
	movups	%xmm0, 116(%rsp)
	setne	66(%rsp)
	subq	$144, %rsp
	.cfi_def_cfa_offset 320
	movdqa	224(%rsp), %xmm1
	movl	288(%rsp), %eax
	movdqa	240(%rsp), %xmm2
	movdqa	256(%rsp), %xmm3
	movdqa	272(%rsp), %xmm4
	movl	%eax, 136(%rsp)
	movdqa	144(%rsp), %xmm5
	movl	208(%rsp), %eax
	movups	%xmm1, 72(%rsp)
	movdqa	160(%rsp), %xmm6
	movups	%xmm2, 88(%rsp)
	movdqa	176(%rsp), %xmm7
	movdqa	192(%rsp), %xmm1
	movl	%eax, 64(%rsp)
	movups	%xmm3, 104(%rsp)
	movups	%xmm4, 120(%rsp)
	movups	%xmm5, (%rsp)
	movups	%xmm6, 16(%rsp)
	movups	%xmm7, 32(%rsp)
	movups	%xmm1, 48(%rsp)
	call	q_finish
	addq	$144, %rsp
	.cfi_def_cfa_offset 176
.L500:
	addq	$168, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L516:
	.cfi_restore_state
	movl	$0, (%rdi)
	jmp	.L505
	.p2align 4,,10
	.p2align 3
.L515:
	movl	%esi, %ecx
	xorl	%eax, %eax
	shrl	$3, %ecx
	andl	$4, %esi
	rep stosq
	je	.L505
	jmp	.L516
	.p2align 4,,10
	.p2align 3
.L506:
	.cfi_def_cfa_offset 8
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE22:
	.size	fh_q_from_shift, .-fh_q_from_shift
	.p2align 4
	.globl	fh_q_normalize
	.type	fh_q_normalize, @function
fh_q_normalize:
.LFB23:
	.cfi_startproc
	testq	%rdi, %rdi
	je	.L519
	subq	$152, %rsp
	.cfi_def_cfa_offset 160
	movdqu	68(%rdi), %xmm0
	movdqu	(%rdi), %xmm4
	movl	132(%rdi), %eax
	movdqu	84(%rdi), %xmm1
	movdqu	100(%rdi), %xmm2
	movdqu	116(%rdi), %xmm3
	movups	%xmm0, 72(%rsp)
	movdqu	16(%rdi), %xmm5
	movdqu	32(%rdi), %xmm6
	movups	%xmm1, 88(%rsp)
	movl	%eax, 136(%rsp)
	movdqu	48(%rdi), %xmm7
	movl	64(%rdi), %eax
	movups	%xmm2, 104(%rsp)
	movups	%xmm3, 120(%rsp)
	movl	%eax, 64(%rsp)
	movups	%xmm4, (%rsp)
	movups	%xmm5, 16(%rsp)
	movups	%xmm6, 32(%rsp)
	movups	%xmm7, 48(%rsp)
	call	q_finish
	addq	$152, %rsp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L519:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE23:
	.size	fh_q_normalize, .-fh_q_normalize
	.p2align 4
	.globl	fh_q_is_canonical
	.type	fh_q_is_canonical, @function
fh_q_is_canonical:
.LFB25:
	.cfi_startproc
	testq	%rdi, %rdi
	je	.L547
	subq	$88, %rsp
	.cfi_def_cfa_offset 96
	movq	%rdi, %r8
	call	limbs_clean
	testl	%eax, %eax
	je	.L527
	leaq	68(%rdi), %rdi
	call	limbs_clean
	testl	%eax, %eax
	je	.L527
	movzwl	132(%r8), %eax
	testw	%ax, %ax
	je	.L527
	cmpb	$0, 134(%r8)
	jne	.L527
	cmpw	$0, 64(%r8)
	jne	.L528
	cmpb	$0, 66(%r8)
	jne	.L527
	cmpw	$1, %ax
	jne	.L527
	xorl	%eax, %eax
	cmpl	$1, 68(%r8)
	sete	%al
	jmp	.L524
	.p2align 4,,10
	.p2align 3
.L528:
	movdqu	68(%r8), %xmm0
	movq	%rsp, %rdi
	subq	$144, %rsp
	.cfi_def_cfa_offset 240
	movups	%xmm0, 72(%rsp)
	movdqu	84(%r8), %xmm1
	movups	%xmm1, 88(%rsp)
	movdqu	100(%r8), %xmm2
	movups	%xmm2, 104(%rsp)
	movdqu	116(%r8), %xmm3
	movups	%xmm3, 120(%rsp)
	movl	132(%r8), %eax
	movl	%eax, 136(%rsp)
	movdqu	(%r8), %xmm4
	movups	%xmm4, (%rsp)
	movdqu	16(%r8), %xmm5
	movups	%xmm5, 16(%rsp)
	movdqu	32(%r8), %xmm6
	movups	%xmm6, 32(%rsp)
	movdqu	48(%r8), %xmm7
	movups	%xmm7, 48(%rsp)
	movl	64(%r8), %eax
	movl	%eax, 64(%rsp)
	call	big_gcd
	addq	$144, %rsp
	.cfi_def_cfa_offset 96
	testl	%eax, %eax
	jne	.L527
	cmpw	$1, 64(%rsp)
	je	.L548
	.p2align 4,,10
	.p2align 3
.L527:
	xorl	%eax, %eax
.L524:
	addq	$88, %rsp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L547:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L548:
	.cfi_def_cfa_offset 96
	cmpl	$1, (%rsp)
	jne	.L527
	xorl	%eax, %eax
	cmpb	$0, 66(%rsp)
	sete	%al
	jmp	.L524
	.cfi_endproc
.LFE25:
	.size	fh_q_is_canonical, .-fh_q_is_canonical
	.p2align 4
	.globl	fh_q_cmp
	.type	fh_q_cmp, @function
fh_q_cmp:
.LFB27:
	.cfi_startproc
	testq	%rsi, %rsi
	sete	%al
	testq	%rdx, %rdx
	sete	%cl
	orb	%cl, %al
	jne	.L550
	testq	%rdi, %rdi
	je	.L550
	jmp	q_cross
	.p2align 4,,10
	.p2align 3
.L550:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE27:
	.size	fh_q_cmp, .-fh_q_cmp
	.p2align 4
	.globl	fh_q_add
	.type	fh_q_add, @function
fh_q_add:
.LFB29:
	.cfi_startproc
	testq	%rdx, %rdx
	movq	%rdx, %rcx
	sete	%al
	testq	%rsi, %rsi
	sete	%dl
	orb	%dl, %al
	jne	.L553
	testq	%rdi, %rdi
	je	.L553
	cmpw	$0, 132(%rdi)
	je	.L555
	cmpw	$0, 132(%rsi)
	je	.L555
	xorl	%edx, %edx
	jmp	q_binop.part.0
	.p2align 4,,10
	.p2align 3
.L555:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L553:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE29:
	.size	fh_q_add, .-fh_q_add
	.p2align 4
	.globl	fh_q_sub
	.type	fh_q_sub, @function
fh_q_sub:
.LFB30:
	.cfi_startproc
	testq	%rdx, %rdx
	movq	%rdx, %rcx
	sete	%al
	testq	%rsi, %rsi
	sete	%dl
	orb	%dl, %al
	jne	.L558
	testq	%rdi, %rdi
	je	.L558
	cmpw	$0, 132(%rdi)
	je	.L560
	cmpw	$0, 132(%rsi)
	je	.L560
	movl	$1, %edx
	jmp	q_binop.part.0
	.p2align 4,,10
	.p2align 3
.L560:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L558:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE30:
	.size	fh_q_sub, .-fh_q_sub
	.p2align 4
	.globl	fh_q_mul
	.type	fh_q_mul, @function
fh_q_mul:
.LFB31:
	.cfi_startproc
	testq	%rdx, %rdx
	movq	%rdx, %rcx
	sete	%al
	testq	%rsi, %rsi
	sete	%dl
	orb	%dl, %al
	jne	.L563
	testq	%rdi, %rdi
	je	.L563
	cmpw	$0, 132(%rdi)
	je	.L565
	cmpw	$0, 132(%rsi)
	je	.L565
	movl	$2, %edx
	jmp	q_binop.part.0
	.p2align 4,,10
	.p2align 3
.L565:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L563:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE31:
	.size	fh_q_mul, .-fh_q_mul
	.p2align 4
	.globl	fh_q_div
	.type	fh_q_div, @function
fh_q_div:
.LFB32:
	.cfi_startproc
	testq	%rdx, %rdx
	movq	%rdx, %rcx
	sete	%al
	testq	%rsi, %rsi
	sete	%dl
	orb	%dl, %al
	jne	.L568
	testq	%rdi, %rdi
	je	.L568
	cmpw	$0, 132(%rdi)
	je	.L570
	cmpw	$0, 132(%rsi)
	je	.L570
	movl	$3, %edx
	jmp	q_binop.part.0
	.p2align 4,,10
	.p2align 3
.L570:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L568:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE32:
	.size	fh_q_div, .-fh_q_div
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%s/%s"
	.text
	.p2align 4
	.globl	fh_q_format
	.type	fh_q_format, @function
fh_q_format:
.LFB34:
	.cfi_startproc
	movq	%rsi, %r11
	movq	%rdx, %rsi
	testq	%r11, %r11
	sete	%al
	cmpq	$3, %rdx
	setbe	%dl
	orb	%dl, %al
	jne	.L603
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	movl	$7, %eax
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rdi, %rbx
	subq	$728, %rsp
	.cfi_def_cfa_offset 784
	testq	%rdi, %rdi
	je	.L571
	movzwl	132(%rdi), %edi
	movl	$6, %eax
	testw	%di, %di
	je	.L571
	movdqu	(%rbx), %xmm0
	movdqu	16(%rbx), %xmm1
	xorl	%r9d, %r9d
	movdqu	32(%rbx), %xmm2
	movdqu	48(%rbx), %xmm3
	movl	64(%rbx), %eax
	cmpb	$0, 66(%rbx)
	movaps	%xmm0, 32(%rsp)
	movzwl	64(%rbx), %r8d
	movaps	%xmm1, 48(%rsp)
	movl	%eax, 96(%rsp)
	movaps	%xmm2, 64(%rsp)
	movaps	%xmm3, 80(%rsp)
	je	.L573
	xorl	%r9d, %r9d
	testw	%r8w, %r8w
	setne	%r9b
.L573:
	testw	%r8w, %r8w
	jne	.L574
	leaq	544(%rsp), %rdx
	movb	$48, 368(%rsp)
	movl	$1, %eax
	leaq	368(%rsp), %r13
	movq	%rdx, 8(%rsp)
.L575:
	cltq
	movdqu	68(%rbx), %xmm4
	movdqu	84(%rbx), %xmm5
	movq	%r11, 16(%rsp)
	movdqu	100(%rbx), %xmm6
	movb	$0, 368(%rsp,%rax)
	leaq	192(%rsp), %r10
	leaq	112(%rsp), %r14
	movl	132(%rbx), %eax
	movdqu	116(%rbx), %xmm7
	movq	%r10, %rbp
	xorl	%ebx, %ebx
	movaps	%xmm4, 112(%rsp)
	leaq	104(%rsp), %r12
	movabsq	$-3689348814741910323, %r9
	movl	%eax, 176(%rsp)
	movaps	%xmm5, 128(%rsp)
	movaps	%xmm6, 144(%rsp)
	movaps	%xmm7, 160(%rsp)
.L588:
	movzwl	%di, %r15d
	movzwl	%di, %eax
	xorl	%ecx, %ecx
	salq	$2, %r15
	subl	$1, %eax
	leaq	-4(%r14,%r15), %r11
	salq	$2, %rax
	addq	%r12, %r15
	subq	%rax, %r15
	movq	%r11, %r8
	.p2align 4,,10
	.p2align 3
.L584:
	movl	(%r8), %eax
	salq	$32, %rcx
	subq	$4, %r8
	orq	%rax, %rcx
	movq	%rcx, %rax
	mulq	%r9
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	movl	%edx, 4(%r8)
	addq	%rax, %rax
	subq	%rax, %rcx
	cmpq	%r8, %r15
	jne	.L584
	movl	(%r11), %eax
	testl	%eax, %eax
	jne	.L606
	.p2align 4,,10
	.p2align 3
.L587:
	subq	$4, %r11
	subw	$1, %di
	je	.L586
	movl	(%r11), %eax
	testl	%eax, %eax
	je	.L587
.L606:
	addl	$48, %ecx
	addl	$1, %ebx
	addq	$1, %rbp
	movb	%cl, -1(%rbp)
	jmp	.L588
	.p2align 4,,10
	.p2align 3
.L586:
	movslq	%ebx, %rax
	leal	1(%rbx), %edi
	addl	$48, %ecx
	movl	%ebx, %ebx
	movb	%cl, 192(%rsp,%rax)
	movslq	%edi, %rdi
	movq	16(%rsp), %r11
	leaq	545(%rsp,%rbx), %rcx
	movq	8(%rsp), %rax
	addq	%rdi, %r10
	.p2align 4,,10
	.p2align 3
.L589:
	movzbl	-1(%r10), %edx
	addq	$1, %rax
	subq	$1, %r10
	movb	%dl, -1(%rax)
	cmpq	%rax, %rcx
	jne	.L589
	movq	8(%rsp), %r8
	movb	$0, 544(%rsp,%rdi)
	xorl	%eax, %eax
	movq	%r13, %rcx
	leaq	.LC0(%rip), %rdx
	movq	%r11, %rdi
	movq	%rsi, 8(%rsp)
	call	snprintf@PLT
	testl	%eax, %eax
	js	.L594
	movq	8(%rsp), %rsi
	cltq
	cmpq	%rsi, %rax
	sbbl	%eax, %eax
	notl	%eax
	andl	$5, %eax
.L571:
	addq	$728, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L574:
	.cfi_restore_state
	leaq	544(%rsp), %rax
	movl	%r9d, 16(%rsp)
	xorl	%r12d, %r12d
	leaq	32(%rsp), %r14
	movq	%rax, 8(%rsp)
	movq	%rax, %rbp
	leaq	24(%rsp), %r13
	movabsq	$-3689348814741910323, %r10
	movw	%di, 30(%rsp)
.L580:
	movzwl	%r8w, %r15d
	movzwl	%r8w, %eax
	xorl	%ecx, %ecx
	salq	$2, %r15
	subl	$1, %eax
	leaq	-4(%r14,%r15), %r9
	salq	$2, %rax
	addq	%r13, %r15
	subq	%rax, %r15
	movq	%r9, %rdi
	.p2align 4,,10
	.p2align 3
.L576:
	movl	(%rdi), %eax
	salq	$32, %rcx
	subq	$4, %rdi
	orq	%rax, %rcx
	movq	%rcx, %rax
	mulq	%r10
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	movl	%edx, 4(%rdi)
	addq	%rax, %rax
	subq	%rax, %rcx
	cmpq	%r15, %rdi
	jne	.L576
	movl	(%r9), %edx
	testl	%edx, %edx
	jne	.L607
	.p2align 4,,10
	.p2align 3
.L579:
	subq	$4, %r9
	subw	$1, %r8w
	je	.L578
	movl	(%r9), %edx
	testl	%edx, %edx
	je	.L579
.L607:
	addl	$48, %ecx
	addl	$1, %r12d
	addq	$1, %rbp
	movb	%cl, -1(%rbp)
	jmp	.L580
	.p2align 4,,10
	.p2align 3
.L578:
	movl	16(%rsp), %r9d
	movslq	%r12d, %rdx
	addl	$48, %ecx
	movzwl	30(%rsp), %edi
	movb	%cl, 544(%rsp,%rdx)
	leal	1(%r12), %eax
	testl	%r9d, %r9d
	jne	.L590
.L581:
	movq	8(%rsp), %r14
	movslq	%eax, %rcx
	leaq	368(%rsp), %r13
	movslq	%r9d, %rdx
	addq	%r13, %rdx
	leaq	-1(%rcx,%r14), %r8
	leaq	(%r14,%rcx), %rax
	movl	%r12d, %ecx
	subq	%rcx, %r8
	.p2align 4,,10
	.p2align 3
.L582:
	movzbl	-1(%rax), %ecx
	subq	$1, %rax
	addq	$1, %rdx
	movb	%cl, -1(%rdx)
	cmpq	%r8, %rax
	jne	.L582
	leal	1(%r12,%r9), %eax
	jmp	.L575
.L590:
	movb	$45, 368(%rsp)
	jmp	.L581
.L603:
	.cfi_def_cfa_offset 8
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	movl	$7, %eax
	ret
.L594:
	.cfi_def_cfa_offset 784
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movl	$5, %eax
	jmp	.L571
	.cfi_endproc
.LFE34:
	.size	fh_q_format, .-fh_q_format
	.p2align 4
	.globl	fh_model_default
	.type	fh_model_default, @function
fh_model_default:
.LFB35:
	.cfi_startproc
	movq	%rdi, %rdx
	movq	$0, (%rdi)
	leaq	8(%rdi), %rdi
	xorl	%eax, %eax
	movq	%rdx, %rcx
	movl	$1, %esi
	movq	$0, 800(%rdi)
	andq	$-8, %rdi
	subq	%rdi, %rcx
	movl	$1, %r8d
	movl	$1, %r9d
	movl	$1, %r10d
	addl	$816, %ecx
	movl	$1, %r11d
	shrl	$3, %ecx
	rep stosq
	movl	$1, %eax
	movl	$1, %ecx
	movl	$1, %edi
	movw	%ax, 132(%rdx)
	movl	$1, %eax
	movw	%ax, 676(%rdx)
	movl	$1, %eax
	movw	%ax, 608(%rdx)
	movl	$1, %eax
	movw	%ax, 812(%rdx)
	movl	$1, %eax
	movl	$1, 68(%rdx)
	movl	$1, (%rdx)
	movw	%cx, 64(%rdx)
	movl	$1, 204(%rdx)
	movw	%si, 268(%rdx)
	movl	$1, 136(%rdx)
	movw	%di, 200(%rdx)
	movl	$1, 340(%rdx)
	movw	%r8w, 404(%rdx)
	movl	$1, 272(%rdx)
	movw	%r9w, 336(%rdx)
	movl	$1, 476(%rdx)
	movw	%r10w, 540(%rdx)
	movl	$1, 408(%rdx)
	movw	%r11w, 472(%rdx)
	movl	$1, 612(%rdx)
	movl	$1, 544(%rdx)
	movl	$1, 748(%rdx)
	movl	$1, 680(%rdx)
	movw	%ax, 744(%rdx)
	ret
	.cfi_endproc
.LFE35:
	.size	fh_model_default, .-fh_model_default
	.p2align 4
	.globl	fh_hard_valid
	.type	fh_hard_valid, @function
fh_hard_valid:
.LFB37:
	.cfi_startproc
	testq	%rdi, %rdi
	je	.L620
	movq	%rdi, %rax
	leaq	6(%rdi), %rcx
.L611:
	movswl	(%rax), %edx
	cmpl	$7, %edx
	ja	.L620
	movswl	6(%rax), %edx
	cmpl	$7, %edx
	ja	.L620
	movswl	12(%rax), %edx
	cmpl	$7, %edx
	ja	.L620
	addq	$2, %rax
	cmpq	%rcx, %rax
	jne	.L611
	movl	$1, %ecx
.L614:
	cmpq	$3, %rcx
	je	.L619
	movzwl	-2(%rdi,%rcx,2), %edx
	movq	%rcx, %rax
	jmp	.L613
	.p2align 4,,10
	.p2align 3
.L612:
	addq	$1, %rax
	cmpl	$3, %eax
	je	.L623
.L613:
	cmpw	(%rdi,%rax,2), %dx
	jne	.L612
	movzwl	6(%rdi,%rax,2), %esi
	cmpw	%si, 4(%rdi,%rcx,2)
	jne	.L612
	movzwl	12(%rdi,%rax,2), %esi
	cmpw	%si, 10(%rdi,%rcx,2)
	jne	.L612
.L620:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L623:
	addq	$1, %rcx
	jmp	.L614
.L619:
	movl	$1, %eax
	ret
	.cfi_endproc
.LFE37:
	.size	fh_hard_valid, .-fh_hard_valid
	.p2align 4
	.globl	fh_energy
	.type	fh_energy, @function
fh_energy:
.LFB39:
	.cfi_startproc
	testq	%rsi, %rsi
	sete	%al
	testq	%rdx, %rdx
	sete	%cl
	orb	%cl, %al
	jne	.L625
	testq	%rdi, %rdi
	je	.L625
	jmp	fh_energy.part.0
	.p2align 4,,10
	.p2align 3
.L625:
	movl	$7, %eax
	ret
	.cfi_endproc
.LFE39:
	.size	fh_energy, .-fh_energy
	.p2align 4
	.globl	fh_authorized
	.type	fh_authorized, @function
fh_authorized:
.LFB41:
	.cfi_startproc
	testq	%rsi, %rsi
	movq	%rsi, %rax
	sete	%cl
	testq	%rdx, %rdx
	sete	%sil
	orb	%sil, %cl
	movl	$0, %esi
	jne	.L626
	testq	%rdi, %rdi
	je	.L626
	cmpl	$1179800404, 8(%rdx)
	je	.L638
.L626:
	movl	%esi, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L638:
	movzbl	(%rdx), %ecx
	cmpb	$2, %cl
	ja	.L626
	movl	$1, %r8d
	movzbl	%cl, %r9d
	sall	%cl, %r8d
	testb	%r8b, 1(%rdx)
	je	.L626
	movl	20(%rdi), %ecx
	cmpl	%ecx, 4(%rdx)
	jne	.L626
	xorl	%edx, %edx
	movl	$-1, %r8d
	xorl	%ecx, %ecx
.L630:
	movzwl	(%rax,%rdx,2), %r10d
	movl	%edx, %esi
	cmpw	%r10w, (%rdi,%rdx,2)
	je	.L639
.L628:
	addl	$1, %ecx
	movl	%esi, %r8d
.L629:
	addq	$1, %rdx
	cmpq	$3, %rdx
	jne	.L630
	cmpl	$1, %ecx
	sete	%sil
	cmpl	%r8d, %r9d
	setne	%al
	andl	%eax, %esi
	xorl	$1, %esi
	movzbl	%sil, %esi
	jmp	.L626
	.p2align 4,,10
	.p2align 3
.L639:
	movzwl	6(%rax,%rdx,2), %r11d
	cmpw	%r11w, 6(%rdi,%rdx,2)
	jne	.L628
	movzwl	12(%rax,%rdx,2), %r11d
	cmpw	%r11w, 12(%rdi,%rdx,2)
	jne	.L628
	jmp	.L629
	.cfi_endproc
.LFE41:
	.size	fh_authorized, .-fh_authorized
	.p2align 4
	.globl	fh_verified
	.type	fh_verified, @function
fh_verified:
.LFB43:
	.cfi_startproc
	movq	%rdi, %rdx
	movq	%rsi, %rcx
	xorl	%eax, %eax
	testq	%rdi, %rdi
	je	.L644
	testq	%rsi, %rsi
	je	.L644
	movl	20(%rdi), %edi
	cmpl	%edi, 20(%rsi)
	jne	.L640
	xorl	%eax, %eax
	xorl	%r9d, %r9d
.L643:
	movswl	(%rdx,%rax), %esi
	movswl	(%rcx,%rax), %edi
	movswl	6(%rcx,%rax), %r8d
	movswl	12(%rcx,%rax), %r10d
	subl	%esi, %edi
	movswl	6(%rdx,%rax), %esi
	subl	%esi, %r8d
	movswl	12(%rdx,%rax), %esi
	subl	%esi, %r10d
	leal	1(%rdi), %esi
	cmpl	$2, %esi
	ja	.L649
	leal	1(%r8), %esi
	cmpl	$2, %esi
	ja	.L649
	leal	1(%r10), %esi
	cmpl	$2, %esi
	ja	.L649
	movl	%edi, %esi
	negl	%esi
	cmovs	%edi, %esi
	movl	%r8d, %edi
	negl	%edi
	cmovs	%r8d, %edi
	addl	%edi, %esi
	movl	%r10d, %edi
	negl	%edi
	cmovs	%r10d, %edi
	addl	%edi, %esi
	cmpl	$1, %esi
	jg	.L649
	sete	%sil
	addq	$2, %rax
	movzbl	%sil, %esi
	addl	%esi, %r9d
	cmpq	$6, %rax
	jne	.L643
	xorl	%eax, %eax
	cmpl	$1, %r9d
	setle	%al
	ret
	.p2align 4,,10
	.p2align 3
.L649:
	xorl	%eax, %eax
.L640:
	ret
	.p2align 4,,10
	.p2align 3
.L644:
	ret
	.cfi_endproc
.LFE43:
	.size	fh_verified, .-fh_verified
	.p2align 4
	.globl	fh_commit
	.type	fh_commit, @function
fh_commit:
.LFB44:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	xorl	%eax, %eax
	movq	%rcx, %r15
	movl	$37, %ecx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	movq	%rdi, %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$648, %rsp
	.cfi_def_cfa_offset 704
	leaq	336(%rsp), %rbp
	movq	%rbp, %rdi
	rep stosq
	movl	$0, (%rdi)
	testq	%r12, %r12
	je	.L652
	testq	%rsi, %rsi
	je	.L652
	testq	%rdx, %rdx
	movq	%rdx, %r14
	sete	%al
	testq	%r15, %r15
	sete	%dl
	orb	%dl, %al
	jne	.L652
	movq	%r8, %rbx
	testq	%r8, %r8
	je	.L652
	cmpb	$2, (%r15)
	ja	.L670
	movl	20(%rsi), %r13d
	cmpl	%r13d, 20(%r14)
	je	.L655
	movl	$7, 336(%rsp)
.L668:
	movq	336(%rsp), %rax
	leaq	8(%rbx), %rdi
	movq	%rbp, %rsi
	andq	$-8, %rdi
	movq	%rax, (%rbx)
	movq	628(%rsp), %rax
	movq	%rax, 292(%rbx)
	subq	%rdi, %rbx
	subq	%rbx, %rsi
	addl	$300, %ebx
	shrl	$3, %ebx
	movl	%ebx, %ecx
	rep movsq
.L652:
	xorl	%eax, %eax
.L651:
	addq	$648, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L655:
	.cfi_restore_state
	leaq	48(%rsp), %rax
	movq	%r12, %rdi
	movq	%rsi, (%rsp)
	movq	%rax, %rdx
	movq	%rax, 24(%rsp)
	call	fh_energy.part.0
	movq	%r12, %rdi
	movq	%r14, %rsi
	movl	%eax, 12(%rsp)
	leaq	192(%rsp), %rax
	movq	%rax, %rdx
	movq	%rax, 16(%rsp)
	call	fh_energy.part.0
	movq	%r14, %rdi
	movl	%eax, %r12d
	call	fh_hard_valid
	movq	(%rsp), %r9
	testl	%eax, %eax
	je	.L671
	movq	%r15, %rdx
	movq	%r14, %rsi
	movq	%r9, %rdi
	movq	%r9, (%rsp)
	call	fh_authorized
	testl	%eax, %eax
	je	.L672
	movq	%r14, %rsi
	call	fh_verified
	testl	%eax, %eax
	je	.L673
	movl	12(%rsp), %edx
	testl	%edx, %edx
	jne	.L674
	testl	%r12d, %r12d
	jne	.L675
	cmpb	$0, 12(%r15)
	jne	.L676
.L662:
	cmpl	$-1, %r13d
	je	.L677
	movdqa	48(%rsp), %xmm0
	movdqa	64(%rsp), %xmm1
	leal	1(%r13), %ecx
	leaq	8(%rbx), %rdi
	movdqa	80(%rsp), %xmm2
	andq	$-8, %rdi
	movq	%rbp, %rsi
	movdqa	96(%rsp), %xmm3
	movdqa	112(%rsp), %xmm4
	movq	176(%rsp), %rax
	movups	%xmm0, 340(%rsp)
	movdqa	128(%rsp), %xmm5
	movups	%xmm1, 356(%rsp)
	movdqa	144(%rsp), %xmm6
	movdqa	192(%rsp), %xmm0
	movups	%xmm2, 372(%rsp)
	movdqa	160(%rsp), %xmm7
	movdqa	208(%rsp), %xmm1
	movups	%xmm3, 388(%rsp)
	movdqa	224(%rsp), %xmm2
	movdqa	240(%rsp), %xmm3
	movups	%xmm4, 404(%rsp)
	movdqa	256(%rsp), %xmm4
	movups	%xmm5, 420(%rsp)
	movdqa	272(%rsp), %xmm5
	movups	%xmm6, 436(%rsp)
	movdqa	288(%rsp), %xmm6
	movq	%rax, 468(%rsp)
	movups	%xmm0, 476(%rsp)
	movups	%xmm7, 452(%rsp)
	movups	%xmm1, 492(%rsp)
	movups	%xmm2, 508(%rsp)
	movups	%xmm3, 524(%rsp)
	movups	%xmm4, 540(%rsp)
	movups	%xmm5, 556(%rsp)
	movups	%xmm6, 572(%rsp)
	movdqa	304(%rsp), %xmm7
	movq	320(%rsp), %rax
	movdqu	(%r14), %xmm0
	movq	%rax, 604(%rsp)
	movq	16(%r14), %rax
	movups	%xmm7, 588(%rsp)
	movq	%rax, 628(%rsp)
	movq	336(%rsp), %rax
	movl	%ecx, 632(%rsp)
	movups	%xmm0, 612(%rsp)
	movq	%rax, (%rbx)
	movq	628(%rsp), %rax
	movq	%rax, 292(%rbx)
	subq	%rdi, %rbx
	movl	$1, %eax
	subq	%rbx, %rsi
	addl	$300, %ebx
	shrl	$3, %ebx
	movl	%ebx, %ecx
	rep movsq
	jmp	.L651
	.p2align 4,,10
	.p2align 3
.L670:
	movl	$8, 336(%rsp)
	jmp	.L668
	.p2align 4,,10
	.p2align 3
.L672:
	movl	$2, 336(%rsp)
	jmp	.L668
	.p2align 4,,10
	.p2align 3
.L671:
	movl	$1, 336(%rsp)
	orl	12(%rsp), %r12d
	jne	.L657
	movdqa	48(%rsp), %xmm0
	movdqa	64(%rsp), %xmm1
	movdqa	80(%rsp), %xmm2
	movdqa	96(%rsp), %xmm3
	movdqa	112(%rsp), %xmm4
	movq	176(%rsp), %rax
	movups	%xmm0, 340(%rsp)
	movdqa	128(%rsp), %xmm5
	movups	%xmm1, 356(%rsp)
	movdqa	144(%rsp), %xmm6
	movdqa	160(%rsp), %xmm7
	movups	%xmm2, 372(%rsp)
	movdqa	192(%rsp), %xmm0
	movdqa	208(%rsp), %xmm1
	movups	%xmm3, 388(%rsp)
	movdqa	224(%rsp), %xmm2
	movdqa	240(%rsp), %xmm3
	movups	%xmm4, 404(%rsp)
	movdqa	256(%rsp), %xmm4
	movups	%xmm5, 420(%rsp)
	movdqa	272(%rsp), %xmm5
	movups	%xmm6, 436(%rsp)
	movdqa	288(%rsp), %xmm6
	movq	%rax, 468(%rsp)
	movups	%xmm7, 452(%rsp)
	movups	%xmm0, 476(%rsp)
	movups	%xmm1, 492(%rsp)
	movups	%xmm2, 508(%rsp)
	movups	%xmm3, 524(%rsp)
	movups	%xmm4, 540(%rsp)
	movups	%xmm5, 556(%rsp)
	movups	%xmm6, 572(%rsp)
	movdqa	304(%rsp), %xmm7
	movq	320(%rsp), %rax
	movq	%rax, 604(%rsp)
	movups	%xmm7, 588(%rsp)
.L657:
	movq	336(%rsp), %rax
	leaq	8(%rbx), %rdi
	movq	%rbp, %rsi
	andq	$-8, %rdi
	movq	%rax, (%rbx)
	movq	628(%rsp), %rax
	movq	%rax, 292(%rbx)
	subq	%rdi, %rbx
	leal	300(%rbx), %ecx
	subq	%rbx, %rsi
	movl	%ecx, %ebx
	shrl	$3, %ebx
	movl	%ebx, %ecx
	rep movsq
	jmp	.L652
	.p2align 4,,10
	.p2align 3
.L673:
	movl	$3, 336(%rsp)
	jmp	.L668
.L674:
	movl	12(%rsp), %eax
	movl	%eax, 336(%rsp)
	jmp	.L668
.L675:
	movl	%r12d, 336(%rsp)
	jmp	.L668
.L676:
	movq	24(%rsp), %rsi
	movq	16(%rsp), %rdi
	leaq	44(%rsp), %rdx
	movl	$0, 44(%rsp)
	call	q_cross
	testl	%eax, %eax
	jne	.L678
	movl	44(%rsp), %eax
	testl	%eax, %eax
	jle	.L662
	movq	24(%rsp), %rsi
	movl	$34, %ecx
	leaq	340(%rsp), %rdi
	movl	$4, 336(%rsp)
	rep movsl
	movq	16(%rsp), %rsi
	leaq	476(%rsp), %rdi
	movl	$34, %ecx
	rep movsl
.L669:
	movq	336(%rsp), %rax
	leaq	8(%rbx), %rdi
	movq	%rbp, %rsi
	andq	$-8, %rdi
	movq	%rax, (%rbx)
	movq	628(%rsp), %rax
	movq	%rax, 292(%rbx)
	subq	%rdi, %rbx
	leal	300(%rbx), %ecx
	subq	%rbx, %rsi
	shrl	$3, %ecx
	rep movsq
	jmp	.L652
.L677:
	movl	$5, 336(%rsp)
	jmp	.L669
.L678:
	movl	%eax, 336(%rsp)
	jmp	.L669
	.cfi_endproc
.LFE44:
	.size	fh_commit, .-fh_commit
	.p2align 4
	.globl	fh_cert_accept
	.type	fh_cert_accept, @function
fh_cert_accept:
.LFB45:
	.cfi_startproc
	testq	%rsi, %rsi
	je	.L680
	movl	$9, (%rsi)
.L680:
	testq	%rdi, %rdi
	je	.L688
	movl	(%rdi), %eax
	cmpl	$1, %eax
	je	.L708
	cmpl	$2, %eax
	je	.L709
	xorl	%edx, %edx
	cmpl	$3, %eax
	je	.L710
.L679:
	movl	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L709:
	movl	16(%rdi), %eax
	xorl	%edx, %edx
	testl	%eax, %eax
	jle	.L679
	movl	20(%rdi), %ecx
	movl	%ecx, %edi
	shrl	$31, %edi
	cmpl	$1000000, %eax
	setg	%dl
	orb	%dil, %dl
	jne	.L688
	cmpl	%ecx, %eax
	jg	.L685
	.p2align 4,,10
	.p2align 3
.L688:
	xorl	%edx, %edx
.L711:
	movl	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L708:
	xorl	%edx, %edx
	cmpl	$8, 4(%rdi)
	ja	.L679
	movl	12(%rdi), %eax
	cmpl	%eax, 8(%rdi)
	jle	.L679
.L685:
	testq	%rsi, %rsi
	je	.L683
	movl	$0, (%rsi)
.L683:
	movl	$1, %edx
	jmp	.L679
	.p2align 4,,10
	.p2align 3
.L710:
	movl	24(%rdi), %eax
	testl	%eax, %eax
	js	.L679
	movl	28(%rdi), %ecx
	cmpl	$2, %eax
	setg	%dl
	cmpl	$2, %ecx
	seta	%dil
	orb	%dil, %dl
	jne	.L688
	cmpl	%ecx, %eax
	jne	.L685
	xorl	%edx, %edx
	jmp	.L711
	.cfi_endproc
.LFE45:
	.size	fh_cert_accept, .-fh_cert_accept
	.section	.rodata.str1.1
.LC1:
	.string	"bounds %d"
.LC2:
	.string	"overlap %d %d"
.LC3:
	.string	"clear"
	.text
	.p2align 4
	.globl	fh_conflict_report
	.type	fh_conflict_report, @function
fh_conflict_report:
.LFB46:
	.cfi_startproc
	movq	%rdi, %rax
	movq	%rsi, %rdi
	movq	%rdx, %rsi
	testq	%rdi, %rdi
	sete	%dl
	testq	%rsi, %rsi
	sete	%cl
	orb	%cl, %dl
	jne	.L722
	testq	%rax, %rax
	je	.L722
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movb	$0, (%rdi)
	xorl	%ecx, %ecx
.L717:
	movswl	(%rax,%rcx,2), %edx
	cmpl	$7, %edx
	ja	.L716
	movswl	6(%rax,%rcx,2), %edx
	cmpl	$7, %edx
	ja	.L716
	movswl	12(%rax,%rcx,2), %edx
	cmpl	$7, %edx
	ja	.L716
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.L717
	xorl	%ecx, %ecx
.L721:
	cmpq	$2, %rcx
	je	.L718
	leaq	1(%rcx), %r9
	movzwl	(%rax,%rcx,2), %edx
	movq	%r9, %r8
	jmp	.L720
	.p2align 4,,10
	.p2align 3
.L719:
	addq	$1, %r8
	cmpl	$3, %r8d
	je	.L729
.L720:
	cmpw	(%rax,%r8,2), %dx
	jne	.L719
	movzwl	6(%rax,%r8,2), %r10d
	cmpw	%r10w, 6(%rax,%rcx,2)
	jne	.L719
	movzwl	12(%rax,%r8,2), %r11d
	cmpw	%r11w, 12(%rax,%rcx,2)
	jne	.L719
	leaq	.LC2(%rip), %rdx
	xorl	%eax, %eax
	call	snprintf@PLT
.L715:
	movl	$12, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L729:
	.cfi_restore_state
	movq	%r9, %rcx
	jmp	.L721
	.p2align 4,,10
	.p2align 3
.L722:
	.cfi_def_cfa_offset 8
	movl	$7, %eax
	ret
.L718:
	.cfi_def_cfa_offset 16
	leaq	.LC3(%rip), %rdx
	xorl	%eax, %eax
	call	snprintf@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L716:
	.cfi_restore_state
	leaq	.LC1(%rip), %rdx
	xorl	%eax, %eax
	call	snprintf@PLT
	jmp	.L715
	.cfi_endproc
.LFE46:
	.size	fh_conflict_report, .-fh_conflict_report
	.p2align 4
	.globl	fh_solver_probe
	.type	fh_solver_probe, @function
fh_solver_probe:
.LFB47:
	.cfi_startproc
	movl	$10, %eax
	ret
	.cfi_endproc
.LFE47:
	.size	fh_solver_probe, .-fh_solver_probe
	.ident	"GCC: (Debian 12.2.0-14+deb12u1) 12.2.0"
	.section	.note.GNU-stack,"",@progbits
