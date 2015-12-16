open Printf
let parse_cmdline ()=
  let input_mode = ref `Not_set in
  let set_input_mode mode =
    if !input_mode <> `Not_set then
      printf "option used more than once on the command line";
    match mode with
    | "disk" | "local" -> input_mode := `Disk
    | "libvirt" -> input_mode := `Libvirt
    | "libvirtxml" -> input_mode := `LibvirtXML
    | "ova" -> input_mode := `OVA
    | s ->
      printf "unknown -i option:";
  in
  let i_options =
    String.concat "|" (Modules_list.input_modules ()) in
  let argspec = [
    "-i", Arg.String set_input_mode, i_options ^ " " ^ s_"Set input mode (default: libvirt)";
  ] in
  let argspec =
;;

parse_cmdline ();;