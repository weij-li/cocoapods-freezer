module Pod
	class Lockfile

		def freered?
			frozen_pods = @internal_data['FROZENPODS']
			if !frozen_pods || frozen_pods.count == 0
				return false
			end

			return true
		end

    def frozen_pod_names
      @internal_data['FROZENPODS'] || []
    end

		class << self
			public
      def generrate_by_freezer(podfile, specs, checkout_options, spec_repos = {}, frozen_pods=[])
        hash = {
          'PODS'             => generate_pods_data(specs),
          'DEPENDENCIES'     => generate_dependencies_data(podfile),
          'SPEC REPOS'       => generate_spec_repos(spec_repos),
          'EXTERNAL SOURCES' => generate_external_sources_data(podfile),
          'CHECKOUT OPTIONS' => checkout_options,
          'SPEC CHECKSUMS'   => generate_checksums(specs),
          'PODFILE CHECKSUM' => podfile.checksum,
          'COCOAPODS'        => CORE_VERSION,
          'FROZENPODS'			 => frozen_pods,
        }
        Lockfile.new(hash)
      end
		end
	end
end