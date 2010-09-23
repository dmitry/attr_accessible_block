class ActiveRecord::Base
  class << self
    alias_method :old_attr_accessible, :attr_accessible
  end
  def self.attr_accessible(*attributes, &block)
    if block_given?
      self.superclass.send :alias_method, :old_attributes=, :attributes=
      define_method :attributes= do |attrs|
        ActiveRecord::AttrAccessible.new(attrs, self, &block)

        send(:old_attributes=, attrs)
      end
    else
      old_attr_accessible(*attributes)
    end
  end
end


class ActiveRecord::AttrAccessible < Array
  attr_reader :attrs, :record

  def initialize(attrs, record, &block)
    @attrs = attrs

    @@before_options.each do |name, func|
      instance_variable_set("@#{name}", func.call)
    end

    @record = record

    unless instance_eval(&@@always_accessible)
      instance_eval(&block)

      flatten!
      reject_attrs!
    end
  end

  def self.before_options(name, func)
    @@before_options ||= {}
    @@before_options[name] = func
    attr_reader name
  end

  def self.always_accessible(&block)
    @@always_accessible = block
  end

  private

  def reject_attrs!
    @attrs.reject! { |k,v| !self.include?(k.to_sym) }
  end
end
