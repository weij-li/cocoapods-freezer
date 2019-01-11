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

        # local not support; 
        if sandbox.local?(spec.name)
          Pod::UI.puts "`#{spec.name}` can't freeze because it is local!".red
          next 
        end

				# fetch targets of pod by spec.name
				pod_targets = installer.pod_targets.select do |target|
					target.root_spec.name == spec.name
				end || []

        # todo(ca1md0wn)
        # Pod has only one target in one platform.
        # 1. pod has multi target beacause of multi platforms in workspace!
        # 2. pod has multi target beacause it define in diffenent targets with diffenent subspec!
        unless pod_targets.count == 1
          Pod::UI.puts "`#{spec.name}` can't freeze because it has multi targets in workspace!".red
          next
        end

        pod_target = pod_targets.first

        # target should not build; 
        if !pod_target.should_build?
          Pod::UI.puts "`#{spec.name}` can't freeze because it should not build!".red
          next
        end

        # todo(ca1md0wn)
        # freezer not support swift; 
        if pod_target.uses_swift?
          Pod::UI.puts "`#{spec.name}` can't freeze because it use swift!".red
          next
        end

        # todo(ca1md0wn)
        # freezer not support to build as framework;
        if pod_target.requires_frameworks?
          Pod::UI.puts "`#{spec.name}` don't support to freeze because it will build as framework!".red
          next
        end

        # todo(ca1md0wn)
        # freezer just support to build at ios; (just support ios now!)
        if pod_target.platform.name != :ios
          Pod::UI.puts "`#{spec.name}` don't support to freeze because it is not ios!".red
          next
        end

        # setup!
				# pod_target build when
        # 1.spec change/add 2.product not exist
        if !unchange_spec_names.include?(spec.name) || !(root + pod_target.product_name).exist?
          product_path = nil
          case pod_target.platform.name
          when :ios then
            # build iphonesimulator!
            iphonesimulator_paths = Pod::Xcodebuild::build_iphonesimulator!(installer.sandbox.project_path.realdirpath, pod_target.name, pod_target.product_name)
            if !iphonesimulator_paths || iphonesimulator_paths.count == 0 
              Pod::UI.puts "`#{spec.name}` don't support to freeze because it build failed!".red
              next
            end

            # build iphoneos!
            iphoneos_paths = Pod::Xcodebuild::build_iphoneos!(installer.sandbox.project_path.realdirpath, pod_target.name, pod_target.product_name)
            if !iphoneos_paths || iphoneos_paths.count == 0
              Pod::UI.puts "`#{spec.name}` don't support to freeze because it build failed!".red
              next
            end

            # lipo!
            product_path = Pod::Lipo::create!(iphoneos_paths + iphonesimulator_paths, pod_target.product_name)

          when :osx then 
            # todo
          when :watchos then
            # todo
          when :tvos then
            # todo
          end

          if !product_path
            Pod::UI.puts "`#{spec.name}` don't support to freeze because it build failed!".red
            next
          end
          
          FileUtils.cp_r(product_path, root + pod_target.product_name, :remove_destination => true)
        end

        frozen_pod = FrozenPod.new(pod_target.pod_name, pod_target.product_name)
        @frozen_pods += [frozen_pod]

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

    def export!(pod_name, path)
      @frozen_pods.select do |frozen_pod|
        if frozen_pod.pod_name == pod_name
          FileUtils.cp_r(root + frozen_pod.product_name, path + frozen_pod.product_name, :remove_destination => true)
          break;
        end
      end
    end

		private

    class FrozenPod
      # [String]
      attr_reader :pod_name

      # [String]
      attr_reader :product_name

      def initialize(pod_name, product_name)
        raise "Params error" unless pod_name.length > 0 && product_name.length > 0
        @pod_name = pod_name
        @product_name = product_name
      end
    end
    
    # [Array<FrozenPod>]
    @frozen_pods

		def root
			Pathname.new(@podfile.defined_in_file.dirname) + 'FrozenPods'
		end

    def manifest_path
      root + 'Manifest.lock'
    end
	end
end