module Pod
	class Command
    class Install < Command
      define_method(:run) do
      	verify_podfile_exists!

        if Freezer::shared.enable?
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
