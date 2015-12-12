require 'net/http'
require 'rexml/document'

module SuperNova
	class Base
		attr_reader :host, :port
		def initialize(host='::1', port='8999')
			@host, @port = host, port
		end
		def get(url)
			Net::HTTP.start(@host, @port) do |http|
				response = http.get(url)
				raise "GET of #{url} failed, #{response.body || '[no body]'}" unless response.code.to_i == 200
				return REXML::Document.new(response.body)
			end
		end
		def delete(url)
			Net::HTTP.start(@host, @port) do |http|
				response = http.delete(url)
				raise "DELETE of #{url} failed, #{response.body||'[no body]'}" unless response.code.to_i == 200
				return REXML::Document.new(response.body)
			end
		end
		def post(url, data)
			Net::HTTP.start(@host, @port) do |http|
				response = http.post(url, data)
				raise "POST to #{url} failed, #{response.body||'[no body]'}" unless response.code.to_i == 200
				return REXML::Document.new(response.body)
			end
		end
		def put(url, data)
			Net::HTTP.start(@host, @port) do |http|
				response = http.put(url, data)
				raise "PUT to #{url} failed, #{response.body||'[no body]'}" unless response.code.to_i == 201
				return REXML::Document.new(response.body)
			end
		end
		def method_missing(sym, *args)
			unless include?(sym)
			raise NoMethodError.new(
				"undefined method `#{method}' for " +
				"#{self.inspect}:#{self.class.name}"
				)
			end
			doc = get(uri(sym.to_s))

			if doc.elements[sym.to_s].nil?
				return doc.root.elements[sym.to_s].text
			end
			return doc.elements[sym.to_s].text
		end
		def include?(sym)
			return false
		end
		def base
			return '/'
		end
		def uri(sym)
			return base()
		end
	end

	class Spine < Base
		def initialize(*args)
			super(*args)
		end
		def ready?
			begin
				get('topology.xml')
			rescue Timeout::Error
				return false
			rescue
				return false
			end
			return true
		end
		def local
			return Node.new(host, port, '/node/')
		end
		def peer
			begin
				peers.first
			rescue Timeout::Error
				return nil
			rescue
				return nil
			end
		end
		def peers
			peers = []
			begin
				doc = get('/nodes/')
				doc.elements.each('nodes/node') do |e|
					if e.attributes['id'] != local.uuid
						peers << Node.new(host, port, "/nodes/id/#{e.attributes['id']}/")
					end
				end
			end
			peers
		end
		def cluster
			return Cluster.new(host, port)
		end
	end

	class Cluster < Base
		attr_reader :base
		def initialize(host, port)
			super(host, port)
			@base = '/cluster/'
		end
		def include?(sym)
			return %w{address authkeys broadcast multicast name netmask prefix ntp_servers time timezone version dom0_memory_target dom0_vcpus_target ramdisk_enabled ramdisk_size}.include?(sym.to_s)
		end
		def ip_config
			return get('/cluster/ip_config')
		end
		def uri(sym)
			return base + sym.to_s
		end
	end

	class Node < Base
		attr_reader :base
		def initialize(host, port, base)
			super(host, port)
			@base = base
		end
		def uuid
			return get(uri(:id)).root.attributes['id']
		end
		def primary?
			get(uri(:primary)).root.attributes['primary'] == 'true'
		end
		def delete!
			return delete(base)
		end
		def include?(sym)
			return %w{name manufacturer model serial timestamp state version pwrstate connectivity systemstorage mode memory}.include?(sym.to_s)
		end
		def uri(sym)
			return base
		end
	end
end
