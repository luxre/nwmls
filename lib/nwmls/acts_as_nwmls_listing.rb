module Nwmls
  module ActsAsNwmlsListing
    extend ActiveSupport::Concern

    BOOLEAN_ATTRIBUTES = [
      :bus_line_nearby,
      :publish_to_internet,
      :senior_exemption,
      :show_address_to_public,
      :show_map_link_to_public,
      :age_restrictions,
      :power_service_in_amps,
      :boundary_survey,
      :dishwasher_unit_1,
      :dishwasher_unit_2,
      :dishwasher_unit_3,
      :dishwasher_unit_4,
      :dishwasher_unit_5,
      :dishwasher_unit_6,
      :environmental_survey,
      :free_and_clear,
      :refrigerator_unit_1,
      :refrigerator_unit_2,
      :refrigerator_unit_3,
      :refrigerator_unit_4,
      :refrigerator_unit_5,
      :refrigerator_unit_6,
      :fireplaces_unit_1,
      :fireplaces_unit_2,
      :fireplaces_unit_3,
      :fireplaces_unit_4,
      :fireplaces_unit_5,
      :fireplaces_unit_6,
      :franchise,
      :furnished,
      :pad_ready,
      :remodeled_updated,
      :range_oven_unit_1,
      :range_oven_unit_2,
      :range_oven_unit_3,
      :range_oven_unit_4,
      :range_oven_unit_5,
      :range_oven_unit_6,
      :unit_can_stay_in_park_after_sale,
      :washer_dryer_unit_1,
      :washer_dryer_unit_2,
      :washer_dryer_unit_3,
      :washer_dryer_unit_4,
      :washer_dryer_unit_5,
      :washer_dryer_unit_6,
      :window_covering,
    ]

    ENCODED_ATTRIBUTES = [
      :status,
      :property_type,
      :basement,
      :cats_and_dogs,
      :electricity,
      :gas,
      :style,
      :lease_terms,
      :loading,
      :major_type_of_business,
      :approved_accessory_dwelling,
      :architecture,
      :building_condition,
      :bonus_room_location,
      :den_or_office_location,
      :environmental_cert,
      :entry_location,
      :form_17,
      :family_room_location,
      :foundation,
      :kitchen_with_eating_space_location,
      :kitchen_location,
      :living_room_location,
      :lot_topography_vegetation,
      :master_bedroom_location,
      :extra_finished_room_location,
      :third_party_approval_required,
      :possession,
      :rec_room_location,
      :potential_terms,
      :utility_room_location,
      :water_source,
      :barn_type,
      :farm_type,
      :type_of_fireplace,
      :leased_terms,
      :terms_and_conditions,
    ]

    MULTI_ENCODED_ATTRIBUTES = [
      :other_rooms,
      :park_amenities,
      :leased_items,
      :dining_room_location,
      :interior_features,
      :appliance_hookups,
      :home_owner_dues_include,
      :parking_types,
      :equipment_included,
      :additional_finished_rooms,
      :assessment_fees,
      :documents_provided,
      :restrictions,
      :amenities,
      :appliances_provided,
      :appliances_that_stay,
      :building_information,
      :barn_features,
      :common_features,
      :community_features,
      :energy_source,
      :exterior,
      :features,
      :fence,
      :floor_covering,
      :property_features,
      :parking_type,
      :general_zoning_classification,
      :heating_and_cooling,
      :improvements,
      :irrigation_source,
      :irrigation_type,
      :leased_equipment,
      :lot_details,
      :licenses,
      :location,
      :livestock_type,
      :move_in_funds_required,
      :manufactured_home_features,
      :new_construction,
      :outbuildings,
      :parking_type,
      :pool,
      :road_information,
      :roof,
      :real_property,
      :site_features,
      :space_rent_includes,
      :soil_type,
      :sewer,
      :topography,
      :terms,
      :type_of_property,
      :unit_features,
      :included_in_rent,
      :view,
      :waterfront,
      :water,
      :zoning_jurisdiction
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
