require "attr_accessible_block/version"

module ActiveModel::MassAssignmentSecurity
  module ClassMethods
    alias_method :old_attr_accessible, :attr_accessible

    def attr_accessible(*attributes, &block)
      if block_given?
        class_attribute(:attr_accessible_block)
        self.attr_accessible_block = block

        include InstanceMethods
      else
        old_attr_accessible(*attributes)
      end
    end

    module InstanceMethods
      def sanitize_for_mass_assignment(attributes, role = :default)
        mass_assignment_authorizer.sanitize(attributes, self)
      end

      def mass_assignment_authorizer
        WhiteListBlock.new(&self.class.attr_accessible_block)
      end
    end
  end

  def attr_accessible?(attribute)
    block = self.class.attr_accessible_block
    attributes = WhiteListBlock.new(&block).sanitize({attribute => send(attribute)}, self)
    attributes.has_key?(attribute)
  end


  class WhiteListBlock < PermissionSet
    attr_reader :attributes, :record

    @@variables = {}
    @@always_accessible = nil

    def sanitize(attributes, record)
      @attributes = attributes

      @@variables.each do |name, func|
        instance_variable_set("@#{name}", func.call)
      end

      @record = record

      always_accessible = (@@always_accessible ? instance_eval(&@@always_accessible) : false)

      unless always_accessible
        instance_eval(&@block)

        flatten!
        reject_attributes!
      end

      @attributes
    end

    def initialize(&block)
      @block = block
      super
    end

    def add(attributes)
      Array.wrap(attributes).map(&:to_s).each { |attribute| super(attribute) }
    end

    def self.add_variable(name, &block)
      @@variables[name] = block
      attr_reader name
    end

    def self.always_accessible(&block)
      @@always_accessible = block
    end

    private

    def reject_attributes!
      @attributes.reject! { |k,v| !include?(k) }
    end
  end
end