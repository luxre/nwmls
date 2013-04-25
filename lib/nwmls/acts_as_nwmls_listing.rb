module Nwmls
  module ActsAsNwmlsListing
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_nwmls_listing(options = {})
        include ActiveModel::Model

        cattr_accessor :property_type
        self.property_type = options[:property_type]

        cattr_accessor :attribute_mappings
        self.attribute_mappings = options[:attribute_mappings]

        attr_accessor(*self.attribute_mappings.values.collect { |v| v.underscore.parameterize('_').to_sym })

        def self.find(conditions = {}, filters = [])
          if conditions.is_a?(Hash)
            conditions.merge!(:property_type => self.property_type)
          end
          super(conditions, filters)
        end

      end
    end
    
  end
end
