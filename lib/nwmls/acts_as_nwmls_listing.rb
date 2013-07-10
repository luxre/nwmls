module Nwmls
  module ActsAsNwmlsListing
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_nwmls_listing(options = {})

        cattr_accessor :attribute_mappings
        self.attribute_mappings = options[:attribute_mappings]

        def self.attributes
          self.attribute_mappings.values.collect { |v| v.underscore.parameterize('_').to_sym }
        end

        attr_accessor(*self.attributes)

        def self.find(conditions = {}, filters = [])
          if conditions.is_a?(Hash)
            conditions.merge!(:property_type => options[:property_type])
          end
          super(conditions, filters)
        end
      end
    end

  end
end
