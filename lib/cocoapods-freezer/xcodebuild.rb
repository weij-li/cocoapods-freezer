module Pod
	module Xcodebuild
		def self.build_iphonesimulator!(project, scheme, product_name)
			output_paths = []
			sdk = 'iphonesimulator'
	    archs = %w(i386 x86_64)
	    archs.each do |arch|
	    	output_path = build!(project, sdk, arch, scheme)
	    	if !output_path
	    		return []
	    	end
	    	
	      output_paths += [output_path + product_name]
	    end

	    output_paths
		end

		def self.build_iphoneos!(project, scheme, product_name)
			output_paths = []
			sdk = 'iphoneos'
	    archs = %w(arm64 armv7 armv7s)
	    archs.each do |arch|
	    	output_path = build!(project, sdk, arch, scheme)
	    	if !output_path
	    		return []
	    	end

	      output_paths += [output_path + product_name]
	    end

	    output_paths
		end

		def self.build_macos!
			# todo
		end

		def self.build_tvos!
			# todo
		end

		def self.build_watchos!
			# todo
		end

		def self.build!(project, sdk, arch, scheme)
			begin
	      output_path = Dir.randdir
	      args = %W(-project #{project.to_s} -scheme #{scheme} -configuration Release CONFIGURATION_BUILD_DIR=#{output_path.to_s} -sdk #{sdk} -derivedDataPath #{Dir.randdir.to_s} -arch #{arch} clean build)
	      Pod::Executable.execute_command("xcodebuild", args, true)
	      # Pod::UI.puts "#{scheme} #{sdk} #{arch} xcodebuild succeed!"
	      return output_path
	    rescue => e
	    	# Pod::UI.puts "#{scheme} #{sdk} #{arch} xcodebuild failed! #{e}"
	    	return nil
	    end
		end
	end
end