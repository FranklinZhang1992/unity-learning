open Printf

class output_everrun path availability = object
  (* inherit output *)

  method as_option =
    match availability with
    | "FT" -> springtf "-o ft -os %s" path
    | "HA" -> springtf "-o ha -os %s" path

  method supported_firmware = [ TargetBIOS; TargetUEFI ]
end