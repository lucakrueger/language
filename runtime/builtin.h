#ifndef BUILTIN_H_
#define BUILTIN_H_

#include "runtime.h"

value_t rprint(value_t *args, unsigned int size) {
    if(size == 0) {
        printf("Runtime error: 'rprint' requires at least one parameter");
        return Atom("none", 5);
    }
    for(int i = 0; i < size; i++) { // go over all params, print each one
        rdprint(args[i]);
    }
    if(size == 1) { // check if size = 1
        return args[0]; // return first and only value
    } else {
        return List(args, size);
    }
}

value_t print(value_t *args, unsigned int size) {
    return rprint(args, size);
}

#endif