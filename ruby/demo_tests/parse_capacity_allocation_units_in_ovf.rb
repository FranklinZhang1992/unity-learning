# PATTERN_REGEXP = "(byte)( \\* ([1-9])((\\^)?([1-9][0-9]*))?)?"
PATTERN_REGEXP = "(byte)( \\* 2\\^([1-9][0-9]*))?"
pattern = Regexp.new(PATTERN_REGEXP)
capacity_allocation_units = "byte * 2^30"
capacity_allocation_units = "byte"

matched = pattern.match(capacity_allocation_units)
p matched
