class Array
	def self.from_attributes(attributes)
		if attributes == nil
			return []
    elsif attributes.is_a?(String) || attributes.is_a?(Pathname)
      return [attributes]
    elsif attributes.is_a?(Array)
    	return attributes
    else
    	raise
    end

    []
	end
end

module Pod

	class Specification
		def done_for_store_freezed
			attributes_hash["source_files"] = []

			available_platforms.map do |spec_platform|
				platform_name = spec_platform.to_sym
				@consumers[platform_name] = Consumer.new(self, platform_name)
			end
		end

		def prepare_to_store_freezed(platform_name)
			(attributes_hash[platform_name] = {}) unless attributes_hash[platform_name]
		end

		def store_freezed_none(platform_name)
			raise unless platform_name && platform_name.is_a?(String)
			attributes_hash[platform_name]["source_files"] = all_source_files(platform_name)
		end

		def store_freezed(platform_name, product_name, product_type)
			raise unless platform_name && platform_name.is_a?(String)
			raise unless product_name && product_name.is_a?(String)
			raise unless product_type

			case product_type
      when :framework then
      	attributes_hash[platform_name]["source_files"] = []
        vendors = Array.from_attributes(attributes_hash[platform_name]["vendored_frameworks"])
        vendors += [product_name]
        attributes_hash[platform_name]["vendored_frameworks"] = vendors
      when :static_library then
      	attributes_hash[platform_name]["source_files"] = header_files_in_all_sources_files(platform_name)
        vendors = Array.from_attributes(attributes_hash[platform_name]["vendored_libraries"])
        vendors += [product_name]
        attributes_hash[platform_name]["vendored_libraries"] = vendors
      else
      	attributes_hash[platform_name]["source_files"] = all_source_files(platform_name)
				return
      end
		end

		private

		def all_source_files_paths(platform_name=nil)
			files = Array.from_attributes(attributes_hash["source_files"])

      if platform_name && attributes_hash[platform_name]
      	files += Array.from_attributes(attributes_hash[platform_name]["source_files"])
      end

      paths = files.map do |file|
      	real_file = file
      	if real_file.is_a?(String)
      		real_file = Pathname.new(real_file)
      	end

      	real_file
      end

      paths
		end

		def all_source_files(platform_name=nil)
			all_source_files_paths(platform_name).map do |path|
        path_s = path
        if !path.is_a?(String)
          path_s = path.to_s
        end

        path_s
      end
		end

		def header_files_paths_in_all_sources_files(platform_name=nil)
			files = all_source_files_paths(platform_name)
			files = files.select do |file|
        file.extname == nil || file.extname.length == 0 || file.extname.to_s.include?("h")
      end.map do |file|
        real_file = file
        if file.extname && file.extname.length > 0
	        real_file = real_file.sub_ext(".{h,hpp}")
        elsif file.to_s.end_with?('*')
          real_file = real_file.sub_ext(".{h,hpp}")
        else # 'file' may be a folder!
          real_file = (real_file + "*").sub_ext(".{h,hpp}")
        end

        real_file
      end

      files
		end

		def header_files_in_all_sources_files(platform_name=nil)
			header_files_paths_in_all_sources_files(platform_name).map do |path|
        path_s = path
        if !path.is_a?(String)
          path_s = path.to_s
        end

        path_s
      end
		end
	end
end