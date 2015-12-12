class Object
	def logDebug(title = nil, &block)
		if title.nil?
			title = self.respond_to?(:log_title) ? self.send(:log_title) : self.class
		end
		$log.debug(title, &block)
	end

	def logInfo(title = nil, &block)
		if title.nil?
			title = self.respond_to?(:log_title) ? self.send(:log_title) : self.class
		end
		$log.info(title, &block)
	end

	def logNotice(title = nil, &block)
		if title.nil?
			title = self.respond_to?(:log_title) ? self.send(:log_title) : self.class
		end
		$log.info(title, &block)
	end

	def logWarning(title = nil, &block)
		if title.nil?
			title = self.respond_to?(:log_title) ? self.send(:log_title) : self.class
		end
		$log.warn(title, &block)
	end

	def logError(title = nil, &block)
		if title.nil?
			title = self.respond_to?(:log_title) ? self.send(:log_title) : self.class
		end
		$log.error(title, &block)
	end

end
