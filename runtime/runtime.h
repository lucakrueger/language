#ifndef RUNTIME_H__
#define RUNTIME_H__

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <math.h>

/*
    TODO:
    - basic operators
    - operator overloading
        - additional operators
    - builtin standard lib
    - standard lib
*/

typedef enum {
    ERR_RUNTIME = 0,
    ERR_OPERATION,
    ERR_TYPE,
    ERR_ARGUMENT
} errType_e;

static const char * const errNames[] = {
    [ERR_RUNTIME] = "Runtime",
    [ERR_OPERATION] = "Operation",
    [ERR_TYPE] = "Type",
    [ERR_ARGUMENT] = "Argument"
};

void throwError(errType_e errType, char *message) {
    printf(errNames[errType]);
    printf(" Error: ");
    printf(message);
    printf("\n");
    exit(0);
}

typedef enum {
    STRING,
    NUMBER,
    ATOM,
    LIST,
    ANY,
    CLASS
} type_e;

static const char * const typeNames[] = {
    [STRING] = "string",
    [NUMBER] = "number",
    [ATOM] = "atom",
    [LIST] = "list",
    [ANY] = "any",
    [CLASS] = "class"
};

typedef struct {
    type_e type;
    void *data;
} value_t; // general value type

typedef struct {
    value_t *values;
    unsigned int size;
} args_t; // args type, used for comparings arguments

typedef value_t (*funPtr)(value_t *, unsigned int);

#define createArgs(values, size) ((args_t){values, size})


typedef struct {
    const char *value;
    unsigned int size;
} string_t;

#define getString(value) (*(string_t *)(value.data))
#define StringLeg(value, size) (((value_t){STRING, &(string_t){value, size}}))

value_t String(char *value, unsigned int size) {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = STRING;
    string_t *tempData = malloc(sizeof(string_t));
    tempData->value = value;
    tempData->size = size;
    temp->data = tempData;
    return *temp;
}

#define copyString(str) (String(getString(str).value, getString(str).size))

typedef struct {
    float value;
} number_t;

#define getNumber(value) (*(number_t *)(value.data))
#define NumberLeg(value) (((value_t){NUMBER, &(number_t){value}}))

value_t Number(float value) {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = NUMBER;
    number_t *tempData = malloc(sizeof(number_t));
    tempData->value = value;
    temp->data = tempData;
    return *temp;
}

#define copyNumber(num) (Number(getNumber(num).value))

typedef struct {
    const char *value;
    unsigned int size;
} atom_t;

#define getAtom(value) (*(atom_t *)(value.data))
#define AtomLeg(value, size) (((value_t){ATOM, &(atom_t){value, size}}))

value_t Atom(char *value, unsigned int size) {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = ATOM;
    atom_t *tempData = malloc(sizeof(atom_t));
    tempData->value = value;
    tempData->size = size;
    temp->data = tempData;
    return *temp;
}

#define copyAtom(at) (Atom(getAtom(at).value, getAtom(at).size))

typedef struct {
    value_t *values;
    unsigned int size;
} list_t;

#define getList(value) (*(list_t *)(value.data))
#define ListLeg(values, size) (((value_t){LIST, &(list_t){values, size}}))
#define len(ls) (((list_t*)ls.data)->size)
#define listIndex(ls, index) (((list_t*)ls.data)->values[index])
#define setList(ls, index, value) ((*(list_t *)(value.data)).values[index] = value)

value_t List(value_t values[], unsigned int size) {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = LIST;
    list_t *tempData = malloc(sizeof(list_t));
    value_t *tempValues = malloc(size * sizeof(value_t));
    for(int i = 0; i < size; i++) {
        tempValues[i] = values[i];
    }
    tempData->values = tempValues;
    tempData->size = size;
    temp->data = tempData;
    return *temp;
}

#define copyList(ls) (List(getList(ls).values, getList(ls).size))

value_t EmptyList(unsigned int size) {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = LIST;
    list_t *tempData = malloc(sizeof(list_t));
    value_t *tempValues = malloc(size * sizeof(value_t));
    for(int i = 0; i < size; i++) {
        tempValues[i] = Atom("none", 5);
    }
    tempData->values = tempValues;
    tempData->size = size;
    temp->data = tempData;
    return *temp;
}

value_t sliceList(value_t ls, int size) {
    value_t result = EmptyList(size);
    for(int i = 0; i < size; i++) {
        getList(result).values[i] = getList(ls).values[i];
    }
    return result;
}

typedef struct {
    int value;
} any_t; // any type

value_t Any() {
    value_t *temp = malloc(sizeof(value_t));
    temp->type = ANY;
    any_t *tempData = malloc(sizeof(any_t));
    tempData->value = 0;
    temp->data = tempData;
    return *temp;
}

#define AnyLeg() ((value_t){ANY, &(any_t){1}})

typedef struct {
    char *op;
    unsigned int oplen;
    funPtr fun; // pointer to overload function
} overload_t;

overload_t NewOverload(char *op, unsigned int oplen, funPtr fun) {
    overload_t *temp = malloc(sizeof(overload_t *));
    temp->op = op;
    temp->oplen = oplen;
    temp->fun = fun;
    return *temp;
}

typedef struct {
	char *name;
	unsigned int namelen;
    unsigned int size;
	char **fields;
	value_t *values;
    overload_t *overloads;
} class_t;

#define getClass(value) (*(class_t *)(value.data))

value_t Class(char *name, unsigned int namelen, unsigned int size, char **fields, value_t *values/*, overload_t *overloads*/) {
	value_t *class = malloc(sizeof(value_t)); // allocate new value_t
    class->type = CLASS;

	// allocate new class_t
	class_t *data = malloc(sizeof(class_t));
	data->name = name;
	data->namelen = namelen;
    data->size = size;
	data->fields = fields;
	data->values = values;
    //data->overloads = overloads;

	class->data = data; // assign new data (class_t)

	return *class;
}

value_t getField(value_t class, char *name) {
    // go over fields
    // check equality
    // return value
    // TODO: Implement hashing later
    for(int i = 0; i < getClass(class).size; i++) {
        if(getClass(class).fields[i] == name) {
            // field found
            return getClass(class).values[i];
        }
    }
    return Atom("none", 5);
}

#define None() (Atom("none", 5))

// helper
bool checkTypes(value_t a, value_t b, type_e t) {
    return (a.type == t && b.type == t);
}

bool compareValues(value_t a, value_t b);

// compare two values with same type
// TODO: Extend to other types
bool compareValuesSameType(value_t a, value_t b) {
    switch(a.type) {
        case STRING:
        {
            string_t stra = getString(a);
            string_t strb = getString(b);

            if(stra.size != strb.size) return false; // check for size
            for(int i = 0; i < stra.size; i++) {
                if(stra.value[i] != strb.value[i]) return false; // check each char O(n)
            }

            return true;
            break;
        }
        case NUMBER:
        {
            return (((number_t*)a.data)->value == ((number_t*)b.data)->value);
            break;
        }
        case ATOM:
        {
            atom_t stra = getAtom(a);
            atom_t strb = getAtom(b);

            if(stra.size != strb.size) return false; // check for size
            for(int i = 0; i < stra.size; i++) {
                if(stra.value[i] != strb.value[i]) return false; // check each char O(n)
            }

            return true;
            break;
        }
        case LIST:
        {
            list_t lsa = getList(a);
            list_t lsb = getList(b);

            if(lsa.size != lsb.size) return false; // check size
            for(int i = 0; i < lsa.size; i++) {
                if(compareValues(lsa.values[i], lsb.values[i]) == false) return false;
            }

            return true;
            break;
        }
    }
    return NULL;
}

bool compareValues(value_t a, value_t b) {
    if(a.type != b.type) return false;
    return compareValuesSameType(a, b);
}

// string helpers
char *concatStrings(char *a, unsigned int lena, char *b, unsigned int lenb) {
    char *buffer = malloc(sizeof(char) * (lena + lenb));
    for(int i = 0; i < lena; i++) {
        buffer[i] = a[i];
    }
    int offset = lena;
    for(int i = 0; i < lenb; i++) {
        buffer[i + offset] = b[i];
    }
    return buffer;
}

// Operations //
value_t op_star(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (NUMBER, NUMBER) -> NUMBER
                    return Number(getNumber(a).value * getNumber(b).value);
                    break;
                }
            }
            break;
        }
    }
    
    throwError(ERR_TYPE, "Undefined operation");
    //return Number(getNumber(a).value * getNumber(b).value);
}
value_t op_plus(value_t b, value_t a) {
    switch(a.type) {
        case STRING:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (STRING, NUMBER) -> STRING
                    string_t stra = getString(a);
                    char buf[50];
                    sprintf(buf, "%g", getNumber(b).value);
                    char *temp = concatStrings(stra.value, stra.size, buf, strlen(buf));
                    //return Number(getNumber(a).value + getNumber(b).value);
                    return String(temp, (stra.size + strlen(buf)));
                    break;
                }
                case STRING:
                {
                    // (STRING, STRING) -> STRING
                    string_t stra = getString(a);
                    string_t strb = getString(b);
                    unsigned int newSize = stra.size + strb.size;
                    char *temp = concatStrings(stra.value, stra.size, strb.value, strb.size);
                    return String(temp, newSize);
                    break;
                }
                case ATOM:
                {
                    // (STRING, ATOM) -> STRING
                    string_t stra = getString(a);
                    atom_t strb = getAtom(b);
                    unsigned int newSize = stra.size + strb.size;
                    char *temp = concatStrings(stra.value, stra.size, strb.value, strb.size);
                    return String(temp, newSize);
                    break;
                }
                case LIST:
                {
                    // (STRING, LIST) -> LIST
                    // add string to list
                    list_t *oldList = (list_t *)b.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    newValues[0] = copyString(a);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i + 1] = oldList->values[i]; // add each element from old list
                    }
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
            }
            break;
        }
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (NUMBER, NUMBER) -> NUMBER
                    return Number(getNumber(a).value + getNumber(b).value);
                    break;
                }
                case STRING:
                {
                    // (NUMBER, STRING) -> NUMBER
                    // convert string to number
                    const char *s = getString(b).value;
                    float convertedb = strtof(s, NULL);
                    return Number(getNumber(a).value + convertedb);
                    break;
                }
                case ATOM:
                {
                    // (NUMBER, ATOM) -> NUMBER
                    // convert atom to number
                    const char *s = getAtom(b).value;
                    float convertedb = strtof(s, NULL);
                    return Number(getNumber(a).value + convertedb);
                    break;
                }
                case LIST:
                {
                    // (NUMBER, LIST) -> LIST
                    // add number to list
                    list_t *oldList = (list_t *)b.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    newValues[0] = copyNumber(a);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i + 1] = oldList->values[i]; // add each element from old list
                    }
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
            }
            break;
        }
        case ATOM:
        {
            switch(b.type) {
                case LIST:
                {
                    // (ATOM, LIST) -> LIST
                    // add atom to list
                    list_t *oldList = (list_t *)b.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    newValues[0] = copyAtom(a);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i + 1] = oldList->values[i]; // add each element from old list
                    }
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
            }
        }
        case LIST:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (LIST, NUMBER) -> LIST
                    // add number to list
                    list_t *oldList = (list_t *)a.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    //newValues[0] = copyNumber(b);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i] = oldList->values[i]; // add each element from old list
                    }
                    newValues[oldList->size] = copyNumber(b);
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
                case STRING:
                {
                    // (LIST, STRING) -> LIST
                    // add string to list
                    list_t *oldList = (list_t *)a.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    //newValues[0] = copyNumber(b);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i] = oldList->values[i]; // add each element from old list
                    }
                    newValues[oldList->size] = copyString(b);
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
                case ATOM:
                {
                    // (LIST, ATOM) -> LIST
                    // add atom to list
                    list_t *oldList = (list_t *)a.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    //newValues[0] = copyNumber(b);
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i] = oldList->values[i]; // add each element from old list
                    }
                    newValues[oldList->size] = copyAtom(b);
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
                case LIST:
                {
                    // (LIST, LIST) -> LIST (does not concatonate lists, just adds other list)
                    // add string to list
                    list_t *oldList = (list_t *)a.data; // get pointer to old list
                    value_t *newValues = malloc(sizeof(value_t) * (oldList->size + 1)); // allocate new memory for new list
                    for(int i = 0; i < (oldList->size); i++) {
                        newValues[i] = oldList->values[i]; // add each element from old list
                    }
                    newValues[oldList->size] = List(getList(b).values, getList(b).size); // ???? deepcopy list !!!
                    free(oldList);
                    return List(newValues, oldList->size + 1);
                    break;
                }
            }
            break;
        }
    }
    
    throwError(ERR_TYPE, "Undefined operation");
    //return Number(getNumber(a).value + getNumber(b).value);
}
value_t op_minus(value_t b, value_t a) {
    switch(a.type) {
        case STRING:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (STRING, NUMBER) -> NUMBER
                    // convert string to number
                    const char *s = getString(a).value;
                    float convertedb = strtof(s, NULL);
                    return Number(convertedb - getNumber(b).value);
                    break;
                }
                case STRING:
                {
                    // (STRING, STRING) -> STRING
                    // go over a char by char -> if b is found -> delete
                    string_t stra = getString(a);
                    string_t strb = getString(b);
                    
                    if(stra.size < strb.size) { // check if a is smaller than b -> no match possible
                        return String(stra.value, stra.size);
                    } else if(stra.size == strb.size) { // equal size, check if both are equal
                        for(int i = 0; i < stra.size; i++) {
                            if(stra.value[i] != strb.value[i]) {
                                // unequal value -> strings are different
                                return copyString(a);
                            }
                            // equal -> return empty string
                            return String("", 1);
                        }
                    }

                    // len(a) > len(b)
                    // a != b
                    // steps: delta(len(a) len(b)) + 1 -> len(a) - len(b) + 1
                    // abcdefg
                    // cde
                    // sec_0: no match a
                    // sec_1: no match ab
                    // sec_2: match ab -> skip to sec s + len(b)
                    // sec_3: no match abd
                    // delta: 7 - 3 + 1 = 5 => 5 steps/sections that get compared

                    // go over a, check a section of len(b) from a if equal to b
                    // if section equal -> dont add chars to buffer
                    // if unequal -> add chars to buffer
                    int sections = stra.size; // calculate delta
                    char buf[stra.size]; // initialize buffer -> size astring, worst case
                    int bufSize = 0; // actual buffer size, gets incremented for each character added

                    for(int s = 0; s < sections; s++) {
                        // check section s
                        bool match = true;
                        for(int i = 0; i < strb.size; i++) {
                            // go over each character in section
                            // s is offset in stra
                            if(stra.value[s+i] != strb.value[i]) { // chars unequal
                                // unequal
                                match = false;
                            }
                        }

                        // check match
                        // if true -> skip to s + len(b) - 1
                        // if false -> add first char of section to buf
                        if(match == true) {
                            /*printf("Section %d\n", s);
                            printf("Sections Total %d\n", sections);
                            printf("len(b) %d\n", strb.size);*/
                            s += strb.size - 1; // skip to next section -> avoids duplicate chars
                        } else {
                            buf[bufSize] = stra.value[s];
                            bufSize += 1;
                        }
                    }

                    char *chars = malloc(sizeof(char) * bufSize); // create malloc new buffer holding buf
                    for(int x = 0; x < bufSize; x++) { // fill
                        chars[x] = buf[x];
                    }

                    return String(chars, bufSize);
                    break;
                }
            }
            break;
        }
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (NUMBER, NUMBER) -> NUMBER
                    return Number(getNumber(a).value - getNumber(b).value);
                    break;
                }
                case STRING:
                {
                    // (NUMBER, STRING) -> NUMBER
                    // convert string to number
                    const char *s = getString(b).value;
                    float convertedb = strtof(s, NULL);
                    return Number(getNumber(a).value - convertedb);
                    break;
                }
                case ATOM:
                {
                    // (NUMBER, ATOM) -> NUMBER
                    // convert atom to number
                    const char *s = getAtom(b).value;
                    float convertedb = strtof(s, NULL);
                    return Number(getNumber(a).value - convertedb);
                    break;
                }
            }
            break;
        }
        case LIST:
        {
            // (LIST, ANY) -> LIST
            // remove number to list

            list_t *oldList = (list_t *)a.data; // get pointer to old list
            //value_t newValuesBuf[oldList->size]; // list of value pointers
            unsigned int newValuesBuf[oldList->size]; // list of indices
            unsigned int newValuesBufSize = 0; // size of buf

            // go over list
            // compare list[i] to b
            // if match -> dont add to buf
            // if not match -> add to buf
            for(int i = 0; i < oldList->size; i++) {
                value_t elem = oldList->values[i];
                bool match = false;
                // check types
                if(elem.type == b.type) {
                    // types match
                    if(compareValuesSameType(elem, b)) { // compare values
                        match = true;
                    }
                }

                if(match == false) {
                    newValuesBuf[newValuesBufSize] = i; // add current index
                    newValuesBufSize += 1; // increment
                }
            }

            value_t *values = malloc(sizeof(value_t) * newValuesBufSize); // initialize new array
            for(int i = 0; i < newValuesBufSize; i++) {
                values[i] = oldList->values[newValuesBuf[i]]; // push each element
            }

            // malloc new memory
            // free old memory
            // return new list
            free(oldList);
            return List(values, newValuesBufSize);
            break;
        }
    }
    
    throwError(ERR_TYPE, "Undefined operation");
    //return Number(getNumber(a).value - getNumber(b).value);
}
value_t op_slash(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    // (NUMBER, NUMBER) -> NUMBER
                    return Number(getNumber(a).value / getNumber(b).value);
                    break;
                }
            }
            break;
        }
    }
    
    throwError(ERR_TYPE, "Undefined operation");
    //return Number(getNumber(a).value * getNumber(b).value);
}
//#define op_star(b, a) (Number(getNumber(a).value * getNumber(b).value))
//#define op_plus(b, a) (Number(getNumber(a).value + getNumber(b).value))
//#define op_minus(b, a) (Number(getNumber(a).value - getNumber(b).value))
value_t op_colon(value_t b, value_t a) {
    switch(a.type) {
        case CLASS:
        {
            return getField(a, getString(b).value);
        }
        case LIST:
        {
            switch(b.type) {
                case NUMBER:
                {
                    return listIndex(a, (int)getNumber(b).value);
                }
            }
        }
    }
    return None();
}
value_t op_eq(value_t b, value_t a) {
    if(compareValues(a, b) == true) return Atom("true", 5);
    return Atom("false", 6);
}
value_t op_geq(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    if(getNumber(a).value >= getNumber(b).value) return Atom("true", 5);
                    return Atom("false", 6);
                }
            }
        }
    }
}
value_t op_greater(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    if(getNumber(a).value > getNumber(b).value) return Atom("true", 5);
                    return Atom("false", 6);
                }
            }
        }
    }
}
value_t op_less(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    if(getNumber(a).value < getNumber(b).value) return Atom("true", 5);
                    return Atom("false", 6);
                }
            }
        }
    }
}
value_t op_plusplus(value_t b, value_t a) {
    switch(a.type) {
        case LIST:
        {
            switch(b.type) {
                case LIST:
                {
                    // concat lists
                    list_t *oldA = (list_t *)a.data;
                    list_t *oldB = (list_t *)b.data;
                    int newSize = (oldA->size + oldB->size);
                    value_t *newValues = malloc(sizeof(value_t) * newSize);
                    for(int i = 0; i < oldA->size; i++) {
                        newValues[i] = oldA->values[i];
                    }
                    for(int i = oldA->size; i < newSize; i++) {
                        newValues[i] = oldB->values[i - oldA->size];
                    }

                    free(oldA);
                    free(oldB);
                    return List(newValues, newSize);
                }
                default:
                {
                    return op_plus(b, a);
                }
            }
        }
        default:
        {
            switch(b.type) {
                default:
                {
                    value_t tempList = EmptyList(2);
                    getList(tempList).values[0] = a;
                    getList(tempList).values[1] = b;
                    return tempList;
                }
            }
        }
    }
}
value_t op_perc(value_t b, value_t a) {
    switch(a.type) {
        case NUMBER:
        {
            switch(b.type) {
                case NUMBER:
                {
                    float fa = getNumber(a).value;
                    float fb = getNumber(b).value;
                    return Number(fmodf(fa, fb));
                    break;
                }
            }
            break;
        }
    }
}

#ifndef RUNTIME_IMPL__
#define RUNTIME_IMPL__

bool isTrue(value_t value) {
    return compareValues(value, Atom("true", 5));
}

// compare arguments
bool compareArgs(args_t a, args_t b) {
    // a, b: args
    if(a.size != b.size) {
        return false; // check if sizes are equal, return false if not
    }
    for(int i = 0; i < a.size; i++) {
        value_t valueA = a.values[i]; // value from a
        value_t valueB = b.values[i]; // value from b
        if(valueA.type == ANY || valueB.type == ANY) { // check for ANY type, automatically accept
            continue;
        }
        if(valueA.type != valueB.type) { // check both types
            return false; // types unequal
        }
        if(compareValuesSameType(valueA, valueB) == false) {
            return false; // compare vlaues, same type already known
        }
    }
    return true;
}

value_t Index(value_t value, value_t index) {
    // TODO: Implement index overloading
    return listIndex(value, (int)(getNumber(index).value));
}

// Debug
void dtprint(value_t value) {
    switch(value.type) {
        case STRING:
        {
            printf("\"");
            printf("%s", getString(value).value);
            printf("\"");
            //printf("\n");
            break;
        }
        case NUMBER:
        {
            char buf[50];
            sprintf(buf, "%g", getNumber(value).value);
            printf(buf);
            //printf("%.2f", getNumber(value).value);
            break;
        }
        case ATOM:
        {
            printf(":");
            printf(getAtom(value).value);
            //printf("\n");
            break;
        }
        case LIST:
        {
            printf("[");
            int sz = len(value);
            for(int i = 0; i < sz; i++) {
                dtprint(listIndex(value, i));
                if(i < (sz - 1)) {
                    printf(", ");
                }
            }
            printf("]");
            //printf("%d", len(value));
            break;
        }
        case ANY:
            printf("any");
            break;
        case CLASS:
        {
            printf("%s", getClass(value).name);
            printf(" {\n");

            for(int i = 0; i < getClass(value).size; i++) {
                printf("\t%s: ", getClass(value).fields[i]);
                dtprint(getClass(value).values[i]);
                printf("\n");
            }

            printf("}\n");
            break;
        }
    }
}

void rdprint(value_t value) {
    dtprint(value);
    printf("\n");
}

#define dmain(fun) int main() { value_t result = fun((value_t[]){}, 0); rdprint(result); return 0; }

#include "builtin.h"

#endif // RUNTIME_IMPL__
#endif // RUNTIME_H__