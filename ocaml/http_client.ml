open Printf

let rec main () =
  printf "main start";;
  let cmd = sprintf "curl -X PUT -d '' http://localhost:8999/pvm" in
  Sys.command cmd;;

main