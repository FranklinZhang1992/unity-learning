module Demo
  extend FFI::Library
  ffi_lib "demo.so"
  attach_function :calculate_something, [:int, :float], :double
end
