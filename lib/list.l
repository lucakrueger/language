sort    | ([]) = []
        | (ls) , [x | xs] : ls = sort({Y X | (Y <- xs) (X = x) | (Y < X) | Y}) ++ x ++ sort({Y X | (Y <- xs) (X = x) | (Y > X) | Y})

search  | ([], n) = []
        | (ls, n) = {x y ?i | (x <- ls) (y = n) | (x = y) | i}

reverse | ([]) = []
        | (ls) , [x | xs] : ls = reverse(xs) ++ x

slice   | ([], from, to) = []
        | (ls, from, to) = { x a b ?i | (x <- ls) (a = from) (b = to) | (i >= a) (i < b) | x }

split | (str, target) , xs : chars(str), indices : ([-1] ++ search(xs, target) ++ listlen(xs)), result : { x chars idc ?i | (x <- indices) (chars = xs) (idc = indices) | (i > 0) | 
    { c a b ?i | (c <- chars) (a = (idc : (i - 1))) (b = (idc : i)) | (i > a) (i < b) | c}
} = { x | (x <- result) | (1 = 1) | fromchars(x) }