module Ownership
  module Owner
    def self.for(*methods, owner:)
      mod = Module.new do
        methods.each { |method_name| Owner.wrap_method(self, method_name, owner) }

        singleton_class.__send__(:define_method, :inspect) do
          "Ownership::Owner.for<#{methods.join(", ")}>"
        end
      end

      Module.new do
        singleton_class.__send__(:define_method, :included) do |base|
          base.prepend(mod)
        end

        singleton_class.__send__(:define_method, :extended) do |base|
          base.singleton_class.prepend(mod)
        end

        singleton_class.__send__(:define_method, :inspect) do
          "Ownership::OwnerInjector"
        end
      end
    end

    def self.wrap_method(target, method_name, owner)
      target.module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{method_name}(*)
          owner #{owner.inspect} do
            super
          end
        end
      RUBY
    end
  end
end
