open Printf

let show () =
    (* let dir = "/home/franklin/workspace/ocaml-demo" in *)
    (* printf "hello\n" *)
    let result = sprintf "hostname" in
    printf "%s" result;
    (* failwith "hello" *)
;;

show ();;