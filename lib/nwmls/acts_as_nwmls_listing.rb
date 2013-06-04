module Nwmls
  module ActsAsNwmlsListing
    extend ActiveSupport::Concern

    BOOLEAN_ATTRIBUTES = [
      :bus_line_nearby,
      :publish_to_internet,
      :senior_exemption,
      :show_address_to_public,
      :show_map_link_to_public,
    ]

    ENCODED_ATTRIBUTES = [
      :status,
      :property_type
    ]

    MULTI_ENCODED_ATTRIBUTES = [
      :unit_features
    ]


    module ClassMethods
      def acts_as_nwmls_listing(options = {})
        include ActiveModel::Model

        cattr_accessor :attribute_mappings
        self.attribute_mappings = options[:attribute_mappings]

        def self.attributes
          self.attribute_mappings.values.collect { |v| v.underscore.parameterize('_').to_sym }
        end

        def self.processed_attributes
          BOOLEAN_ATTRIBUTES + ENCODED_ATTRIBUTES + MULTI_ENCODED_ATTRIBUTES
        end

        def self.readable_attributes
          self.attributes - self.processed_attributes
        end

        attr_writer(*self.attributes)
        attr_reader(*self.readable_attributes)

        def self.find(conditions = {}, filters = [])
          if conditions.is_a?(Hash)
            conditions.merge!(:property_type => options[:property_type])
          end
          super(conditions, filters)
        end
      end
    end

    BOOLEAN_ATTRIBUTES.each do |method|
      define_method method do
        case instance_variable_get("@#{method}")
        when 'Y' then true
        when 'N' then false
        end
      end
      alias_method "#{method}?", method
    end

    ENCODED_ATTRIBUTES.each do |method|
      define_method method do
        value = instance_variable_get("@#{method}")
        if value
          I18n::t("#{method}.#{value}")
        end
      end
    end

    MULTI_ENCODED_ATTRIBUTES.each do |method|
      define_method method do
        values = instance_variable_get("@#{method}")
        if values
          values.split('|').collect { |value| I18n::t("#{method}.#{value}")}
        end
      end
    end

  end
end
