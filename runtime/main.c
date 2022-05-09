#include "runtime.h"

/*
	{x <- ls | (x % 2 = 0) | x}
	value_t function(value_t ls)
		value_t x = None();
		for(int iter = 0; iter < ls->size; iter++) {
			x = ls.values[iter];
			if(isTrue(op_eq((op_percent(Number(2.0), x)), 0))) {

			}
		}
*/

value_t set_ZIHZvP(value_t iteratorList, value_t x) {
	value_t elem = None();
	value_t returning = EmptyList(getList(iteratorList).size);
	int curr = 0;
	for(int iter = 0; iter < getList(iteratorList).size; iter++) {
		elem = getList(iteratorList).values[iter];
		x = elem;
		if( isTrue(op_eq((Number(0.f)),op_perc((Number(2.f)),(x)))) ) {
			getList(returning).values[curr] = x;
			curr++;
		}
	}
	return sliceList(returning, curr);
}

value_t setTest(value_t *values, unsigned int size) {
	args_t args = createArgs(values, size);

	value_t values0[] = {Any()};
	args_t args0 = createArgs(values0, 1);
	if(compareArgs(args, args0)) {
		value_t ls = values[0];
		value_t returning = EmptyList(getList(ls).size);
		value_t elem = None(); // initliaze elem
		int curr = 0;
		for(int iter = 0; iter < getList(ls).size; iter++) {
			elem = getList(ls).values[iter];
			value_t x = elem;
			if(isTrue(op_eq(Number(0.0), op_perc(Number(2.0), x)))) {
				getList(returning).values[curr] = x;
				curr++;
			}
		}
		return returning;
	}
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
	//value_t ret = setTest((value_t[]){ls}, 1);
	value_t ret = set_ZIHZvP(ls, ls);
	return ret;
}

dmain(test);