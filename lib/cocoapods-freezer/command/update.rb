module Pod
	class Command
    class Update < Command
      define_method(:run) do
        verify_podfile_exists!

        # not support 'pod update'
        # todo(ca1md0wn)
        Freezer.shared.enable(false)

        installer = installer_for_config
        installer.repo_update = repo_update?(:default => true)
        if @pods
          verify_lockfile_exists!
          verify_pods_are_installed!
          installer.update = { :pods => @pods }
        else
          UI.puts 'Update all pods'.yellow
          installer.update = true
        end
        installer.install!
      end
    end
  end
end