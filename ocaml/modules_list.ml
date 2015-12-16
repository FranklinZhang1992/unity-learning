let input_modules = ref []

let register_input_module name =
    input_modules := name :: !input_modules

let input_modules () = List.sort compare !input_modules