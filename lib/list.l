sort    | ([]) = []
        | (ls) , [x | xs] : ls = sort({Y X | (Y <- xs) (X = x) | (Y < X) | Y}) ++ x ++ sort({Y X | (Y <- xs) (X = x) | (Y > X) | Y})

search  | ([], n) = []
        | (ls, n) = {x y ?i | (x <- ls) (y = n) | (x = y) | i}

reverse | ([]) = []
        | (ls) , [x | xs] : ls = reverse(xs) ++ x