open Printf

type people = {
  s_name : string;
};;

let main() =
  let arr = ref [] in

  (* Prepend List *)
(*   let add name =
    arr := {
      s_name = name;
    } :: !arr in *)

  (* Join Lists *)
  let add name =
    arr := !arr @ [{
      s_name = name;
    }] in

  add "a";
  add "b";
  add "c";

  List.iter (
    fun a ->
      printf "%s\n" a.s_name;
  ) !arr;
;;

main();
