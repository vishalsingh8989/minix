//===-- floatundidf.S - Implement __floatundidf for i386 ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements __floatundidf for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// double __floatundidf(du_int a);

#ifdef __i386__

#if defined(__APPLE__)
	.const
#elif defined(__ELF__)
	.section .rodata
#else
	.section .rdata,"rd"
#endif

	.balign 16
twop52:
	.quad 0x4330000000000000

	.balign 16
twop84_plus_twop52:
	.quad 0x4530000000100000

	.balign 16
twop84:
	.quad 0x4530000000000000

#define REL_ADDR(_a)	(_a)-0b(%eax)

.text
.balign 4
DEFINE_COMPILERRT_FUNCTION(__floatundidf)
	movss	8(%esp),						%xmm1 // high 32 bits of a
	movss	4(%esp),						%xmm0 // low 32 bits of a
	calll	0f
0:	popl	%eax
	orpd	REL_ADDR(twop84),				%xmm1 // 0x1p84 + a_hi (no rounding occurs)
	subsd	REL_ADDR(twop84_plus_twop52),	%xmm1 // a_hi - 0x1p52 (no rounding occurs)
	orpd	REL_ADDR(twop52),				%xmm0 // 0x1p52 + a_lo (no rounding occurs)
	addsd	%xmm1,							%xmm0 // a_hi + a_lo   (round happens here)
	movsd	%xmm0,						   4(%esp)
	fldl   4(%esp)
	ret
END_COMPILERRT_FUNCTION(__floatundidf)

#endif // __i386__
