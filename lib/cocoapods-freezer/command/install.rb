module Pod
	class Command
    class Install < Command
      require 'cocoapods-freezer/command/options/frozen'
      include Frozen

      define_method(:run) do
      	verify_podfile_exists!

        if frozen?
          unless frozen_root.nil?
            Freezer::shared.root = frozen_root
          end

          Freezer::shared.freeze!
        elsif Config.instance.sandbox.manifest && Config.instance.sandbox.manifest.freered?
          Config.instance.sandbox.clear!
        end

        installer = installer_for_config
        installer.repo_update = repo_update?(:default => false)
        installer.update = false
        installer.install!
      end
    end
  end
end
