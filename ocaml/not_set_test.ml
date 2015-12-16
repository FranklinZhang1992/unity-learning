open Printf

let parse_cmdline () =
  let arg = ref false in
  if !arg = false then
    Printf.printf "false";
;;