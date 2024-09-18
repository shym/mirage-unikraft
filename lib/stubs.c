#ifdef __Unikraft__

#include <caml/callback.h>
#include <pthread.h>
#include <assert.h>

void *uk_caml_main(void *argv) {
    caml_startup((char**) argv);
    return NULL;
}

int main(int argc, char **argv) {
    pthread_t m;
    assert(pthread_create(&m, NULL, &uk_caml_main, argv) == 0);
    assert(pthread_join(m, NULL) == 0);
    return 0;
}

#endif
