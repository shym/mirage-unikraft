#ifdef __Unikraft__

#include <caml/callback.h>
#include <uk/sched.h>

void caml_yield(void) {
  uk_sched_yield();
}

int main(int argc, char **argv) {
    caml_startup(argv);
    return 0;
}

#else

void caml_yield(void) {}

#endif
