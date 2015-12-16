open Printf

class virtual output = object
  method virtual as_options :string
  method keep = true
end

class output_libvirt oc output_pool = object
  inherit output
  method as_options =
    match oc with
    | None -> sprintf "-os %s" output_pool
    | Some uri -> sprintf "-oc %s -os %s" uri output_pool

  method prepare = output_pool
end;;

let output_libvirt = new output_libvirt;;


let output = output_libvirt "/dev" "default";;
let o = output#as_options;;
printf "%s" o;;
