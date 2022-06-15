@use std.l

@entry
@deprecated
@custom ("h")
test | () = a_custom

@ :: custom | () = print(:ok)
            | (n) = print(:err)