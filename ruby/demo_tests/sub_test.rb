# str = "abc abc"
# p str.sub("abc", "X")

str = '/nodes/id/123456/protected-virtual-machine'
segments = str.sub('/nodes/', '').split('/')
lookup = segments.shift
p lookup