/* SPDX-License-Identifier: MIT */
/*
 * Authors: Fabrice Buoro <fabrice@tarides.com>
 *          Samuel Hym <samuel@tarides.com>
 *
 * Copyright (c) 2024-2025, Tarides.
 *               All rights reserved.
*/

#ifdef __Unikraft__

#include <assert.h>
#include <pthread.h>

#include <uk/plat/time.h>

#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

int main(int argc, char **argv) {
    caml_startup(argv);
    return 0;
}

CAMLprim value caml_get_monotonic_time(value v_unit)
{
    CAMLparam1(v_unit);
    __nsec ns = ukplat_monotonic_clock();
    CAMLreturn(caml_copy_int64(ns));
}

#endif /* __Unikraft__ */
