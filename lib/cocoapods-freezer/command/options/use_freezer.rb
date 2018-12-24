module Pod
  class Command
    module Options
      # Provides support for commands to skip updating the spec repositories.
      #
      module UseFreezer

        module Options
          def options
            [
              ['--use-freezer', 'running cocoapods-freeze before install'],
            ].concat(super)
          end
        end

        def self.included(base)
          base.extend(Options)
        end

        def use_freezer?(default: false)
          if @use_freezer.nil?
            default
          else
            @use_freezer
          end
        end

        def initialize(argv)
          @use_freezer = argv.flag?('use-freezer')
          super
        end
      end
    end
  end
end
