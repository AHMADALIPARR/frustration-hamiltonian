# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later

CC ?= gcc
CFLAGS ?= -std=c11 -Wall -Wextra -Werror -O2 -Iinclude
LDFLAGS ?=

.PHONY: test clean test-compile-fail test-link-fail asm m2 host ampl demo

GM2 ?= /opt/fh-tools/usr/bin/x86_64-linux-gnu-gm2-12
GM2LIB ?= /opt/fh-tools/usr/lib/gcc/x86_64-linux-gnu/12
SYSGC ?= /usr/lib/gcc/x86_64-linux-gnu/12
GM2FLAGS ?= -fpim -fno-use-linker-plugin -I $(GM2LIB)/m2/m2pim -I m2 -L $(GM2LIB)/m2/m2pim -L $(SYSGC) -flibs=pim

test: build/test_fh
	./build/test_fh

demo: build/demo
	./build/demo

build/demo: c/fh_kernel.c c/demo.c include/fh.h
	mkdir -p build
	$(CC) $(CFLAGS) -o build/demo c/fh_kernel.c c/demo.c $(LDFLAGS)

build/test_fh: c/fh_kernel.c c/test_fh.c include/fh.h
	mkdir -p build
	$(CC) $(CFLAGS) -o build/test_fh c/fh_kernel.c c/test_fh.c $(LDFLAGS)

build/fh_kernel.o: c/fh_kernel.c include/fh.h
	mkdir -p build
	$(CC) $(CFLAGS) -c -o build/fh_kernel.o c/fh_kernel.c

build/libfh.a: build/fh_kernel.o
	ar rcs build/libfh.a build/fh_kernel.o

build/fh_host.o: c/fh_host.c include/fh.h
	mkdir -p build
	$(CC) $(CFLAGS) -c -o build/fh_host.o c/fh_host.c

asm: build/libfh.a
	mkdir -p asm
	$(CC) $(CFLAGS) -S -o asm/fh_kernel.s c/fh_kernel.c
	sha256sum asm/fh_kernel.s c/fh_kernel.c include/fh.h > asm/SHA256SUMS

m2:
	mkdir -p build
	cd m2 && $(GM2) $(GM2FLAGS) -o ../build/m2rat M2RatTest.mod

host: build/fh_kernel.o build/fh_host.o
	mkdir -p build
	cd m2 && $(GM2) $(GM2FLAGS) -o ../build/fh-host Host.mod ../build/fh_host.o ../build/fh_kernel.o

ampl:
	glpsol --math ampl/feasible.mod
	glpsol --math ampl/infeasible.mod

test-compile-fail:
	mkdir -p build
	if $(CC) $(CFLAGS) -c -o build/bad.o c/expect_compile_fail.c; then exit 1; else exit 0; fi

test-link-fail: build/libfh.a
	if $(CC) $(CFLAGS) -o build/link_fail c/expect_link_fail.c; then exit 1; else exit 0; fi

clean:
	rm -rf build
