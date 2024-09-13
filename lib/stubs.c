#ifdef __Unikraft__

#include <caml/callback.h>
#include <uk/plat/bootstrap.h>

void caml_halt() {
    ukplat_halt();
}

int main(int argc, char **argv) {
    caml_startup(argv);
    return 0;
}

#else

#include <stdlib.h>

void caml_halt() {
    exit(0);
}

#endif
