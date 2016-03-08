# list = []
# list << "aa"
# list << "bb"
# list << "cc"
# p list
# str = "aa/bb/cc"
# list = str.split("/")
# p list
# p list.shift


def request_path
  "/nodes/id/681e84fd-b06b-4044-9c51-2b74a9e2dc24/storage/id/d66570fa-9d51-4f6e-ab26-bdace295353e"
end

def path_sub(request_path, path)
  segments = request_path.sub(path, '').split('/')
  return if segments.size == 0
  lookup = segments.shift
  puts lookup
end

path_sub(request_path, "/")
path_sub(request_path, "/nodes/")
path_sub(request_path, "/nodes/id/")
path_sub(request_path, "/nodes/id/681e84fd-b06b-4044-9c51-2b74a9e2dc24/")
path_sub(request_path, "/nodes/id/681e84fd-b06b-4044-9c51-2b74a9e2dc24/storage/")
path_sub(request_path, "/nodes/id/681e84fd-b06b-4044-9c51-2b74a9e2dc24/storage/id/")
path_sub(request_path, "/nodes/id/681e84fd-b06b-4044-9c51-2b74a9e2dc24/storage/id/d66570fa-9d51-4f6e-ab26-bdace295353e/")
