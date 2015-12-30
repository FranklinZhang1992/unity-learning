require 'webrick'

module Net
    module WebDAV
        class ClientError < StandardError
            def initialize(body = '', type = 'text/plain')
                @body = body
                @type = type
            end
            def body
                @body
            end
            def prepare(response)
                response.status = @status
                response['content-type'] = @type
                response.body = self.body
            end
        end
        class Accepted < ClientError
            def initialize(body = '', type = 'text/plain')
                super
                @status = 202
            end
        end
        class BadRequest < ClientError
            def initialize(body = '', type = 'text/plain')
                super
                @status = 400
            end
        end
        class Forbidden < ClientError
            def initialize(body = '', type = 'text/plain')
                super
                @status = 403
            end
        end
        class NotFound < ClientError
            def initialize(body = '', type = 'text/plain')
                super
                @status = 404
            end
        end

        module Prepare
            def Prepare.ok(response, body = '')
                response.status = 200
                response['content-type'] = 'text/plain'
                response.body = body
            end
            def Prepare.created(response, body = '')
                response.status = 201
                response['content-type'] = 'text/plain'
                response.body = body
            end
            def Prepare.method_not_allowed(response, body = '')
                response.status = 405
                response['content-type'] = 'text/plain'
                response.body = body
            end
            def Prepare.bad_request(response, body = '')
                response.status = 400
                response['content-type'] = 'text/plain'
                response.body = body
            end
            def Prepare.not_found(response, body = '')
                response.status = 404
                response['content-type'] = 'text/plain'
                response.body = body
            end
            def Prepare.server_error(response, exception)
                response.status = 500
                response['content-type'] = 'text/plain'
                response.body = exception
            end
        end

        class Resource < WEBrick::HTTPServlet::AbstractServlet
            def log_title
                'WebDAV'
            end
            def initialize(server, filename, controller = nil)
                super(server)
                @filename = filename
                @controller = controller
            end
            def name
                @filename
            end
            def parent=(collection)
                @parent = collection
            end
            def get_instance(server, *options)
                self
            end
            def path
                return @filename if @parent.nil?
                @parent.path + @filename
            end
            def do_POST(request, response)
                logNotice { "POST #{request.path}"}
                begin
                    case
                    when self.respond_to?(:post); data = post(request.body)
                    when @controller.nil?; return Prepare.not_found(response)
                    when @controller.respond_to?(:post); data = @controller.post(request.body)
                    else raise Forbidden.new
                    end
                rescue ClientError => exception
                    exception.prepare(response)
                rescue Exception => exception
                    Prepare.server_error(response, exception)
                else
                    Prepare.ok(response, data)
                end
            end
            def do_PUT(request, response)
                logNotice { "PUT #{request.path}" }
                begin
                    method = :put
                    case
                    when self.respond_to?(method); data = self.__send__(method, request.body)
                    when @controller.nil?; return Prepare.not_found(response)
                    when @controller.respond_to?(method); data = @controller.__send__(method, request.body)
                    else raise Forbidden.new
                    end
                rescue NoMethodError => e
                    Prepare.method_not_allowed(response)
                rescue ClientError => e
                    e.prepare(response)
                rescue Exception => exception
                    Prepare.server_error(response, exception)
                else
                    return Prepare.created(response, data)
                end
            end
            def do_GET(request, response)
                logNotice{ "Resource do get, request path = #{request.path}, filename = #{@filename}" }
                begin
                    case
                    when self.respond_to?(:get); data = get
                    when @controller.nil?; return Prepare.not_found(response)
                    when @controller.respond_to?(:get); data = @controller.get
                    else raise Forbidden.new
                    end
                rescue ClientError => exception
                    exception.prepare(response)
                rescue Exception => exception
                    Prepare.server_error(response, exception)
                else
                    return Prepare.ok(response, data)
                end
            end
        end

        class Collection < Resource
            def initialize(server, filename, controller = nil)
                super(server, filename, controller)
                @views = Hash.new
                @children = []
            end
            def children
                @children + @views.values
            end
            def push_children(child)
                @children << child
            end
            def add_view(type, name, controller)
                resource = type.new(@server, name, controller)
                resource.parent = self
                @views[name] = resource
                resource
            end
            def add_collection(name, controller)
                add_view(Collection, name, controller)
            end
            def path
                return '/' if @parent.nil?
                @parent.path + @filename + '/'
            end
            def do_GET(request, response)
                logDebug{ "collection do get, request path = #{request.path}, filename = #{@filename}" }
                segments = request.path.sub(path, '').split('/')
                lookup = segments.shift
                handler = @views[lookup]
                if handler.nil?
                    handler = children.detect { |child| child.name == lookup }
                    return Prepare.not_found(response) if handler.nil?
                end
                return Prepare.method_not_allowed(response) unless handler.respond_to? :do_GET
                begin
                    handler.do_GET(request, response)
                rescue ClientError => exception
                    exception.prepare(response)
                rescue Exception => exception
                    Prepare.server_error(response, exception)
                end
            end

            def do_POST(request, response)
                logDebug {"#{Time.now} - POST #{request.path} body => #{request.body}"}
                segments = request.path.sub(path, '').split('/')
                logDebug {"current segments is #{segments}"}
                return super(request, response) if segments.size == 0
                lookup = segments.shift
                handler = @views[lookup]
                logDebug {"current lookup is #{lookup}"}
                logDebug {"current @views => #{@views.keys}"}
                if handler.nil?
                    logDebug {"current children => "}
                    handler = children.detect { |child|
                        logDebug {"#{child.name}" }
                        child.name == lookup
                    }
                    return Prepare.not_found(response) if handler.nil?
                end
                return Prepare.method_not_allowed(response) unless handler.respond_to? :do_POST
                begin
                    handler.do_POST(request, response)
                rescue ClientError => exception
                    exception.prepare(response)
                rescue Exception => exception
                    Prepare.server_error(response, exception)
                end
            end

            def do_PUT(request, response)
                logDebug {"#{Time.now} - PUT #{request.path} body => #{request.body}"}
                segments = request.path.sub(path, '').split('/')
                lookup = segments.shift
                handler = @views[lookup]
                if handler.nil?
                    handler = children.detect { |child| child.name == lookup }
                end
                if handler.nil?
                    begin
                        case
                        when self.respond_to?(:put); result = put
                        when @controller.respond_to?(:put); result = @controller.put
                        else raise Forbidden.new
                    end
                    rescue ClientError => exception
                        exception.prepare(response)
                    rescue NoMethodError => e
                        return Prepare.method_not_allowed(response)
                    rescue ArgumentError => e
                        return Prepare.bad_request(response)
                    rescue Exception => exception
                        return Prepare.not_found(response)
                    else
                        return Prepare.created(response, result)
                    end
                end
                return Prepare.method_not_allowed(response) unless handler.respond_to? :do_PUT
                handler.do_PUT(request, response)
            end
        end

        class Dictionary < Collection
            def initialize(server, filename, controller, view=Resource)
                super(server, filename, controller)
                @id = add_collection('id', controller)
                @id.instance_variable_set('@view', view)
                def @id.children
                    @controller.inject([]) do |list, child|
                        resource = @view.new(@server, child.id.to_s, child)
                        resource.parent = self
                        list << resource
                    end
                end
                # @id.push_children(inject_resource('1', view))
                # @id.push_children(inject_resource('2', view))
            end
            def inject_resource(id, view)
                resource = view.new(@server, id)
                resource.parent = self
                return resource
            end
        end
    end
end
