module Pod
	module Lipo
		def self.create!(paths, product_name)
			output_path = Dir.mkranddir + product_name

			begin
				command = "lipo -create"
				paths.each do |pathname|
				  command += " " + pathname.to_s
				end

				command += "  -output #{output_path}"
				`#{command}`
				# Pod::UI.puts "lipo succeed!"
			rescue => e
				# Pod::UI.puts "lipo failed! #{e}"
			end

			output_path
		end
	end
end