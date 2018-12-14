module Pod
	class Sandbox
		def clear!
			root.rmtree if root.exist?
		end
	end
end