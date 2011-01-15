class ActiveRecord::Base
  class << self
    alias_method :old_attr_accessible, :attr_accessible
  end
  def self.attr_accessible(*attributes, &block)
    if block_given?
      write_inheritable_attribute(:attr_accessible_block, block)
      self.superclass.send :alias_method, :old_attributes=, :attributes=
      define_method :attributes= do |attrs|
        ActiveRecord::AttrAccessibleBlock.new(attrs, self, &block)

        send(:old_attributes=, attrs)
      end
    else
      old_attr_accessible(*attributes)
    end
  end

  def attr_accessible?(attribute)
    klass = self.class
    block = klass.read_inheritable_attribute(:attr_accessible_block)
    if block
      attributes = {attribute => nil}
      ActiveRecord::AttrAccessibleBlock.new(attributes, self, &block)
      attributes.has_key?(attribute)
    else
      # rails 2/3 compatibility
      if klass.respond_to?(:accessible_attributes)
        klass.accessible_attributes.include?(attribute.to_s)
      else
        klass._accessible_attributes.include?(attribute)
      end
    end
  end
end


class ActiveRecord::AttrAccessibleBlock < Array
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
