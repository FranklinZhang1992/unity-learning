# force = "true"
# force = force == "true" ? true : false

# p force

class Demo

    def pro()
        puts "get pro"
    end
    def pro=(val)
        puts "set pro #{val}"
    end

    def test
        # self.send("pro=", "xxx")
        pro = "xxx"
    end
end

demo = Demo.new
demo.test
