module Pod
	class Podfile

		@use_freezer = false

		def use_freezer?
			@use_freezer
		end

		def freezer_path
			@freezer_path
		end

		def freezer_all?
			@freezer_all || false
		end
		
		module DSL
			def use_freezer!(options=nil)
				@use_freezer = true

				if !options || !options[:options]
					return
				end

				options_hash = options[:options]

				@freezer_all = options_hash[:all]
				#@freezer_path =  options_hash[:path]
			end
		end
	end
end