search  | ([], n) = []
        | (ls, n) = {x y ?i | (x <- ls) (y = n) | (x = y) | i}

split | (str, target) , xs : chars(str), indices : ([-1] ++ search(xs, target) ++ listlen(xs)), result : { x chars idc ?i | (x <- indices) (chars = xs) (idc = indices) | (i > 0) | 
    { c a b ?i | (c <- chars) (a = (idc : (i - 1))) (b = (idc : i)) | (i > a) (i < b) | c}
} = { x | (x <- result) | (1 = 1) | fromchars(x) }

type :: Mail | name?
             | addr?
             | ext?

getMail | (acc), first : split(acc, "@") , second : split((first : 1), ".") = Mail((first : 0), (second : 0), (second : 1))

match | (str, model) , matches : { elem s m ?i | (elem <- model) (s = str) (m = model) | (i % 2 = 0) | split(s, elem) } = matches

getMailNew | (acc) = match(acc, [:name, "@", :addr, ".", :ext])

main->m | () = getMailNew("lucakr@outlook.de")