require 'tmpdir'

module Pod
	class Freezer
		def self.shared
			@shared ||= (Config.instance.podfile ? new(Config.instance.podfile) : nil)
		end

    def initialize(podfile)
      raise unless podfile
      @podfile = podfile
      @frozen_pods = [] 
      @enable = false
    end

    def enable?
      @enable
    end

    def exist?
      root.exist?
    end

    def clear!
      root.rmtree if root.exist?
    end

    # freeze!
    # todo(ca1md0wn): if Dir of FrozenPods destoryed, should fix by itself!
		def freeze!
      @enable = true

      Pod::UI.puts "Freezing Pods".green

      unchange_spec_names = []
      if manifest_path.exist?
        lockfile = Pod::Lockfile.from_file(manifest_path)
        unchange_spec_names = Pod::Installer::Analyzer::SpecsState.new(lockfile.detect_changes_with_podfile(@podfile)).unchanged.to_a
      end

			# prepare root dir
			root.mkpath unless root.exist?

			# prepare sandbox
      sandbox = Pod::Sandbox.new(Dir.randdir)

      # install!
      installer = Pod::Installer.new(sandbox, @podfile , nil)
      installer.repo_update = false # todo(ca1md0wn)
      installer.update = false # todo(ca1md0wn)
      installer.use_by_freezer = true
      installer.install!

      specs_for_freezing = installer.major_specs
      
      # freeze!
			specs_for_freezing.each do |spec|

        # subspec not support;
        if spec.subspecs.count > 0
          Pod::UI.puts "`#{spec.name}` can't freeze because it has subspecs!".red
          next
        end

        # local not support; 
        if sandbox.local?(spec.name)
          Pod::UI.puts "`#{spec.name}` can't freeze because it is local!".red
          next 
        end

				# fetch targets of pod by spec.name
				pod_targets = installer.pod_targets.select do |target|
					target.root_spec.name == spec.name
				end || []

        unless pod_targets.count > 0
          Pod::UI.puts "`#{spec.name}` can't freeze because it nil!".red
          next
        end

        not_support = false
        pod_targets.each do |target|
          # todo(ca1md0wn)
          # should_not_build not support 
          if !target.should_build?
            Pod::UI.puts "`#{spec.name}` can't freeze because it should not build!".red
            not_support = true
            break
          end

          # todo(ca1md0wn)
          # swift not support; 
          if target.uses_swift?
            Pod::UI.puts "`#{spec.name}` can't freeze because it use swift!".red
            not_support = true
            break
          end

          # todo(ca1md0wn)
          # build_as_framework not support;
          if target.requires_frameworks?
            Pod::UI.puts "`#{spec.name}` don't support to freeze because it will build as framework!".red
            not_support = true
            break
          end

          # todo(ca1md0wn)
          # multiplatform not support(just support ios now!)
          if target.platform.name != :ios
            Pod::UI.puts "`#{spec.name}` don't support to freeze because it is not ios!".red
            not_support = true
            break
          end
        end
        next if not_support

        frozen_pod = FrozenPod.new(spec.name)

        # setup!
				pod_targets.each do |target|
          # target build when
          # 1.spec change/add 2.product not exist
          if !unchange_spec_names.include?(spec.name) || !(root + target.product_name).exist?

            product_path = nil
            case target.platform.name
            when :ios then
              # build iphonesimulator!
              iphonesimulator_paths = Pod::Xcodebuild::build_iphonesimulator!(installer.sandbox.project_path.realdirpath, target.name, target.product_name)
              if !iphonesimulator_paths || iphonesimulator_paths.count == 0 
                next
              end

              # build iphoneos!
              iphoneos_paths = Pod::Xcodebuild::build_iphoneos!(installer.sandbox.project_path.realdirpath, target.name, target.product_name)
              if !iphoneos_paths || iphoneos_paths.count == 0
                next
              end

              # lipo!
              product_path = Pod::Lipo::create!(iphoneos_paths + iphonesimulator_paths, target.product_name)

            when :osx then 
              # todo
            when :watchos then
              # todo
            when :tvos then
              # todo
            end

            next unless product_path
            
            FileUtils.cp_r(product_path, root + target.product_name, :remove_destination => true)
          end

          frozen_pod.mark!(target.product_name)
				end

        unless frozen_pod.empty?
          @frozen_pods += [frozen_pod]
        end

        Pod::UI.puts "`#{spec.name}` freeze!".green
			end

      # save manifest file
      if sandbox.manifest_path.exist?
        FileUtils.cp_r(sandbox.manifest_path, manifest_path, :remove_destination => true)
      end

      Pod::UI.puts "Pods freeze complete!".green
		end

    def frozen_pod_names
      pod_names = @frozen_pods.map do |frozen_pod|
        frozen_pod.pod_name
      end

      pod_names || []
    end

    def freezed_pod?(pod_name)
      @frozen_pods.each do |frozen_pod|
        if frozen_pod.pod_name == pod_name
          return true
        end
      end

      return false
    end

    def freezed_product?(product_name)
      @frozen_pods.each do |frozen_pod|
        frozen_pod.product_names.each do |name|
          if name == product_name
            return true
          end
        end
      end

      return false
    end

    def export!(product_name, path)
      if !path || !freezed_product?(product_name)
        return
      end

      FileUtils.cp_r(root + product_name, path.to_s, :remove_destination => true)
    end

		private

    class FrozenPod
      # String
      attr_reader :pod_name

      # Array<String>
      attr_reader :product_names

      def initialize(pod_name)
        @pod_name = pod_name
        @product_names = []
      end

      def mark!(product_name)
        @product_names += [product_name]
      end

      def empty?
        if @product_names.count > 0
          return false
        end

        return true
      end
    end
    
    # Array<FrozenPod>
    @frozen_pods

		def root
			Pathname.new(@podfile.defined_in_file.dirname) + 'FrozenPods'
		end

    def manifest_path
      root + 'Manifest.lock'
    end
	end
end