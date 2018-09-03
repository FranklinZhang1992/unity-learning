require 'delegate'
require 'singleton'

class CollectionFilter < Delegator
    def initialize(controller, sorter=nil, &filter)
        super(controller)
        @controller = controller
        @sorter = sorter
        @filter = filter
    end
    def __getobj__() @controller end
    def __setobj__(obj) @controller = obj end
    def each()
        list = @controller.inject([]) { |l,v| l << v if @filter.call(v); l }
        list = list.sort(&@sorter) if @sorter
        list.each {|o| yield o }
    rescue 
        [ ]
    end
    def size() @controller.inject(0) { |l,v| l += 1 if @filter.call(v); l } end
    def length() size end
    include Enumerable
    def empty?() self.each { return false }; return true end
end

class App
    attr :dom_id
    attr :name
    def initialize(dom_id, name)
        @dom_id = dom_id
        @name = name
    end
end

class Service
    include Singleton
    attr :apps

    def initialize
        @apps = []
    end

    def apps=(a)
        @app << a
    end
end

def srv() Service.instance end

class Demo
    attr :id
    def initialize(id)
        @id = id
    end
    def apps
        if !@apps && srv.apps
            puts "enter apps"
            @apps = CollectionFilter.new(srv.apps) { |app|
                puts "XXX, id: #{self.id}, dom_id: #{app.dom_id}"
                self.id == app.dom_id
            }
        end
        @apps || []
    end
end

d1 = Demo.new("1111")
app1 = App.new("1111", "app1")
app2 = App.new("1111", "app2")
app3 = App.new("1112", "app3")

srv.apps << app1
srv.apps << app2
srv.apps << app3


app4 = App.new("1111", "app4")
d1.apps.each do |app|
    puts "app name: #{app.name}, dom id: #{app.dom_id}"
end
srv.apps << app4
d1.apps.each do |app|
    puts "app name: #{app.name}, dom id: #{app.dom_id}"
end
