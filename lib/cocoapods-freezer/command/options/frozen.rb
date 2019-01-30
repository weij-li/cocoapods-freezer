module Pod
  class Command
    module Options
      # Provides support for commands to skip updating the spec repositories.
      #
      module Frozen

        module Options
          def options
            [
              ['--frozen', 'running cocoapods-freezer before install'],
              ['--frozen=~/Workspace', 'running cocoapods-freezer before install'],
            ].concat(super)
          end
        end

        def self.included(base)
          base.extend(Options)
        end

        def frozen?(default: false)
          if @frozen.nil?
            default
          else
            @frozen
          end
        end

        def frozen_root
          @frozen_root
        end

        def initialize(argv)
          argv_frozen = argv.option('frozen')
          if argv_frozen.nil?
            @frozen = argv.flag?('frozen')
          else
            @frozen = true
            root = Pathname.new(argv_frozen)
            if root.directory?
              @frozen_root = root
            else
              root.mkdir
              if root.directory?
                @frozen_root = root
              end
            end
          end

          super
        end
      end
    end
  end
end
