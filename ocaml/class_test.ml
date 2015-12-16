open Printf

class demo par =
  let g = printf "new class %s\n" par in
  object(self)
  method get_g = g
end

let demo = new demo "demo"