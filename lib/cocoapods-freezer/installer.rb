module Pod
	class Installer

    def major_specs
      root_specs
    end

    def clean_pods_about_freezed
      Pod::Freezer.shared.frozen_pod_names.each do |pod_name|
        sandbox.clean_pod(pod_name)
      end

      if sandbox.manifest && sandbox.manifest.frozen_pod_names
        sandbox.manifest.frozen_pod_names.select do |pod_name|
          !Pod::Freezer.shared.frozen_pod_names.include?(pod_name)
        end.each do |pod_name|
          sandbox.clean_pod(pod_name)
        end
      end
    end

    def resolve_dependencies_about_freezed
      major_specs.each do |major_spec|
        next unless Pod::Freezer.shared.freezed_pod?(major_spec.name)

        targets = pod_targets.select do |target|
          target.pod_name == major_spec.name
        end

        # Pod has only one target
        unless targets.count == 1
          next
        end

        target = targets.first

        # Pod maybe include multi subspecs, 
        all_specs = analysis_result.specifications.select do |spec|
          spec.root.name == major_spec.name
        end.each do |spec|
          spec.prepare_to_store_freezed(target.platform.name.to_s)
          spec.store_freezed(target.platform.name.to_s, target.product_name, target.product_type)
          spec.done_for_store_freezed
        end
      end
    end

    def install_source_of_pod_about_freezed(pod_name)
      if Pod::Freezer.shared.freezed_pod?(pod_name)
        Pod::Freezer.shared.export!(pod_name, self.sandbox.pod_dir(pod_name))
      end
    end

    attr_accessor :use_by_freezer
    @use_by_freezer

		# hook integrate_user_project
    hook_integrate_user_project = instance_method(:integrate_user_project)
    define_method(:integrate_user_project) do
      # ignore when install by freezer
      if @use_by_freezer
        return
      end

      hook_integrate_user_project.bind(self).()
    end

    # hook resolve_dependecies
    hook_resolve_dependecies = instance_method(:resolve_dependencies)
    define_method(:resolve_dependencies) do

      # no hook when install by freezer
      if @use_by_freezer || !Pod::Freezer.shared.enable?
        analyzer = hook_resolve_dependecies.bind(self).()
      else
        clean_pods_about_freezed
        analyzer = hook_resolve_dependecies.bind(self).()
        resolve_dependencies_about_freezed
      end

      analyzer
    end

    # hook install_source_of_pod

    hook_install_source_of_pod = instance_method(:install_source_of_pod)
    define_method(:install_source_of_pod) do |pod_name|
      # no hook when install by freezer
      if @use_by_freezer || !Pod::Freezer.shared.enable?
        hook_install_source_of_pod.bind(self).(pod_name)
        return
      end

      pod_installer = create_pod_installer(pod_name)
      pod_installer.install!
      install_source_of_pod_about_freezed(pod_name)
      @installed_specs.concat(pod_installer.specs_by_platform.values.flatten.uniq)
    end

    # hook write_lockfiles

    hook_write_lockfiles = instance_method(:write_lockfiles)
    define_method(:write_lockfiles) do
      # no hook when install by freezer
      if @use_by_freezer || !Pod::Freezer.shared.enable?
        hook_write_lockfiles.bind(self).()
        return
      end

      external_source_pods = analysis_result.podfile_dependency_cache.podfile_dependencies.select(&:external_source).map(&:root_name).uniq
      checkout_options = sandbox.checkout_sources.select { |root_name, _| external_source_pods.include? root_name }

      @lockfile = Lockfile.generrate_by_freezer(podfile, analysis_result.specifications, checkout_options, analysis_result.specs_by_source, Pod::Freezer.shared.frozen_pod_names)
      UI.message "- Writing Lockfile in #{UI.path config.lockfile_path}" do
        @lockfile.write_to_disk(config.lockfile_path)
      end

      UI.message "- Writing Manifest in #{UI.path sandbox.manifest_path}" do
        sandbox.manifest_path.open('w') do |f|
          f.write config.lockfile_path.read
        end
      end
    end
	end
end