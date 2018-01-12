# Generate random number with Time as seed
(0..10).each {srand(Time.now.to_i); print rand(10), " "; sleep 1}
print "\n"

# Generate random number with same seed
(0..10).each {srand(1); print rand(10), " "}
print "\n"
