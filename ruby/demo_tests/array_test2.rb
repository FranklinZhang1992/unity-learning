def show_arr(arr)
    puts "arr = #{arr}, first = #{arr.first}, last = #{arr.last}"
    puts "first.nil? = #{arr.first.nil?}, last.nil? = #{arr.last.nil?}"
    puts "==============="
end

def concat_arr(arr1, arr2, arr3)
    arr = []
    arr += arr1
    arr += arr2
    arr += arr3
    p arr
end

# show_arr(nil)
# show_arr([])
# show_arr(["a"])
# show_arr(["a", "b"])

arr1 = ["1"]
arr2 = []
arr3 = ["2", "3"]
concat_arr(arr1, arr2, arr3)
