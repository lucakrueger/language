#ifndef BUILTIN_H_
#define BUILTIN_H_

#include "runtime.h"
#include <pthread.h>

value_t threads(value_t *args, unsigned int size) {
    /*
        threads(...list *fun): list
    */
    if(size == 0) {
        printf("Runtime error: 'threads' requires at least one parameter");
        return Atom("none", 5);
    }

    int i;
    pthread_t tid;
    for(i = 0; i < size; i++) {
        
    }
    
}

/* IO */
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

/* STRINGS */
value_t chars(value_t *args, unsigned int size) {
    if(size != 1) {
        printf("Runtime error: 'chars' requires only one parameter");
        return Atom("none", 5);
    }
    string_t str = getString(args[0]);

    // go over string chars -> create new string for each char
    // push list

    char *chars = str.value;
    value_t list = EmptyList(str.size);
    for(int i = 0; i < str.size; i++) {
        char *temp = malloc(sizeof(char)); // malloc new array
        temp[0] = chars[i]; // set char
        getList(list).values[i] = String(temp, 1); // new string
    }
    //free(list.data);

    return list;
}

value_t listlen(value_t *args, unsigned int size) {
    return Number((float)getList(args[0]).size);
}

value_t fromchars(value_t *args, unsigned int size) {
    if(size != 1) {
        printf("Runtime error: 'fromchars' requires only one parameter");
        return Atom("none", 5);
    }
    // TODO: Implement
    char *chars = malloc(sizeof(char) * getList(args[0]).size);
    for(int i = 0; i < getList(args[0]).size; i++) {
        chars[i] = getString(getList(args[0]).values[i]).value[0];
    }
    value_t temp = String(chars, getList(args[0]).size);
    return temp;
}

/* PERFORMANCE */
value_t get_time(value_t *args, unsigned int size) {
    clock_t time = clock();
    return Number((float)time);
}

value_t clocks_per_sec(value_t *args, unsigned int size) {
    return Number((float)CLOCKS_PER_SEC);
}

value_t to_dec(value_t *args, unsigned int size) {
    char *buf = malloc(sizeof(char) * 11);
    sprintf(buf, "%.8f", getNumber(args[0]).value);
    return String(buf, 50);
}

#endif