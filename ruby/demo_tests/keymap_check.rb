require 'set'

SUPPORTED_LANGUAGE = %w{ar de-ch es fo fr-ca hu ja mk no pt-br sv da en-gb et fr fr-ch is lt nl pl ru th de en-us fi fr-be hr it lv nl-be pt sl tr}

def check(language)
  return SUPPORTED_LANGUAGE.to_set.include?(language)
end

puts check("abad")
