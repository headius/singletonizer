require 'thread'

module Singletonizer
  LOCK = Mutex.new
  def def(name, &block)
    LOCK.synchronize do
      (@attached_methods ||= {})[name] = block
      class_method = :"__class_#{name}"
      return if respond_to? class_method
      if respond_to? name
        self.class.class_eval {alias_method class_method, name}
      else
        self.class.class_eval <<-RUBY
          def #{class_method}(*args)
            ex = NoMethodError.new("undefined method `#{name}' for \#{self.inspect}:\#{self.class}")
            ex.set_backtrace caller(2)
            raise ex
          end
        RUBY
      end
      self.class.class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(*args)
          if (defined? @attached_methods) && (block = @attached_methods[:#{name}])
            instance_exec(*args, &block)
          else
            __class_#{name}(*args)
          end
        end
      RUBY
    end
  end
end