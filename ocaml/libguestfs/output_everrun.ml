open Printf

class output_everrun domain_path availability = object
  (* inherit output *)

  method as_option =
    match availability with
    | "FT" -> springtf "-o everrunft -os %s" domain_path
    | "HA" -> springtf "-o everrunha -os %s" domain_path

  method supported_firmware = [ TargetBIOS; TargetUEFI ]

  (* method prepare_targets source targets = *)
    (* 1. check whether the domain exists *)
end