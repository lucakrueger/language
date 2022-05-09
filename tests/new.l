fac | (0) = 1
    | (n) = n * fac(n - 1)

fib | (0) = 0
    | (1) = 1
    | (n) = fib(n - 1) + fib(n - 2)

vec | (x, y) = [:vec, x, y]
vec::+  | (a, b) = [:vec, a->1 + b->1, a->2 + b->2]
        | (a, b) = [:vec, {a + b}->[1], {a + b}->[2]] // common index chain

f(g(x)) = {f o g}->(x)

(:vec + :vec)::(a, b) = [:vec] ++ { i <- a | :true | (a + b)[i] } // -> overloading
