class Dir
	def self.randdir
		path = nil
    while (path == nil || path.exist?) do
      path = Pathname.new(Dir.tmpdir + rand(999999).to_s) #todo(ca1md0wn)
    end

    path
	end

	def self.mkranddir
		path = randdir
    path.mkpath
    path
	end
end