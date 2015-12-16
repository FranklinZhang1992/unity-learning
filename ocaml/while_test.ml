open Printf

let main =
  let i = 0 in
  let quit_loop = ref false in
  while not !quit_loop do
    print_string "Have you had enough yet? (y/n) ";
    let j = i;
    let x = j + 1;
    if i > 2 then
      quit_loop := true
  done;;

main