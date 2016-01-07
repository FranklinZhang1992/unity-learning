class Domain
    NAME_RE = Regexp.new('^[a-zA-Z0-9][\w\-\.]*$') # Check size limit separately
    def self.name_re() NAME_RE end

    RESERVED_NAME_PREFIXES = %w{Zombie- migrating-} # Xend renames domains using these prefixes
    def self.reserved_name_prefixes() RESERVED_NAME_PREFIXES end
    RESERVED_NAME_RE = Regexp.new("^(#{RESERVED_NAME_PREFIXES.join('|')})")
    def self.reserved_name_re() RESERVED_NAME_RE end

    # Limit domain name length such that the default volume name won't be too long
    def self.name_length_max() 127 - 37 - "_vol0".length end  # 37 accounts for ".{uuid}" suffix
    def rename(name)
      new_name = name
      new_name.match(Domain.name_re) or raise Exception, "VM name must conform to the regular expression #{Domain.name_re}"
      new_name.match(Domain.reserved_name_re) and
          raise Exception, "VM name cannot use a reserved prefix matching "+Domain.reserved_name_prefixes.map {|a| "'#{a}'"} .join(' or ')+'.'
      puts "max length is #{Domain.name_length_max}"
      new_name.size > Domain.name_length_max and raise Exception, "VM name can be no more than #{Domain.name_length_max} characters"
      puts "it's ok"
    end
end

puts %w{Zombie- migrating-}
domain = Domain.new
domain.rename("vm")
