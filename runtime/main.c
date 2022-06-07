#include "runtime.h"
#include "extension.h"

value_t ol_op_plus_Vector(value_t *args, unsigned int size) {
	return None();
}

value_t Person(value_t name, value_t age) {
	char **fields = malloc(sizeof(char *) * 3);
	fields[0] = "name";
	fields[1] = "age";
	fields[2] = "addr";

	value_t *values = malloc(sizeof(value_t) * 3);
	values[0] = name;
	values[1] = age;
	values[2] = String("nowhere",7);

	overload_t *overloads = malloc(sizeof(overload_t) * 1);
	overloads[0] = NewOverload("op_plus", 7, &ol_op_plus_Vector);

	value_t temp = Class("Person", 7, 3, fields, values, overloads);
	return temp;
}

value_t test(value_t *args, unsigned int size) {
    /*value_t str = String("Hello Runtime", 14);
	rdprint(str);
	printf("\n");
	value_t ls = List(((value_t[]){String("Hello", 6), Atom("World", 6)}), 2);
	rdprint(ls);
    return Number(0.0);*/
	value_t ls = List((value_t[]){
		Number(0.0), Number(1.0), Number(2.0), Number(3.0), Number(4.0), Number(5.0),
		Number(6.0), Number(7.0), Number(8.0), Number(9.0), Number(10.0), Number(12.0)
	}, 12);
	rdprint(ls);

	value_t temp = Person(String("Krüger", 8), Number(20));

	dtprint(getField(temp, "addr"));
	printf("\n");

	return temp;
	//value_t ret = setTest((value_t[]){ls}, 1);
}

dmain(test);