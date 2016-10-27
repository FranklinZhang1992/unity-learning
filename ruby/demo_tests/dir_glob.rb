BASE_PATH = "/home/franklin/temp"

class Kit
    attr :path
    attr :uuid
    def initialize(uuid)
      @uuid = uuid
    end
end

class KitManager
  def initialize
      @kits = []
  end
  def load_kits
      Dir.glob("#{BASE_PATH}/????????-????-????-????-????????????") do |kitdir|
          next unless File.directory?(kitdir) and File.file?("#{kitdir}/kit.xml")
          file_uuid = File.basename(kitdir)
          next if @kits.index{ |k| k.uuid == file_uuid }  # found already
          kit = Kit.new(file_uuid) 
          @kits << kit
      end
      p @kits
  end
end

km = KitManager.new
km.load_kits
