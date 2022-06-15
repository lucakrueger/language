@use std.l

@entry
test | () = addls([3, 5], [4, 2])

af | (n) = n + 2
bf | (n) = n * 3

addls | (a, b) = [{af + bf}(2), {af + bf}(3)]