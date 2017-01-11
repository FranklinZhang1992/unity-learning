begin
    folder = "/tmp/folder_delete"
    file = "#{folder}/file_delete"
    %x{mkdir #{folder}}
    %x{touch #{file}}
    File.delete(folder)
rescue Exception => e
    raise
end
