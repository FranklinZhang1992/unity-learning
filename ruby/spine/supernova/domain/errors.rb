module SuperNova
	class DomainError < RuntimeError; end
	class InvalidDomain < DomainError; end
	class InvalidDomainConfig < DomainError; end
end
