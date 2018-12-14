module Pod
	class Config
		def freezer
			return nil unless podfile

			@freezer ||= new(podfile) 
		end
	end
end