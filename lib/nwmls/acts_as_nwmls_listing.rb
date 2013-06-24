module Nwmls
  module ActsAsNwmlsListing
    extend ActiveSupport::Concern

    BOOLEAN_ATTRIBUTES = [
      :age_restrictions,
      :boundary_survey,
      :bus_line_nearby,
      :dishwasher_unit_1,
      :dishwasher_unit_2,
      :dishwasher_unit_3,
      :dishwasher_unit_4,
      :dishwasher_unit_5,
      :dishwasher_unit_6,
      :environmental_survey,
      :fireplaces_unit_1,
      :fireplaces_unit_2,
      :fireplaces_unit_3,
      :fireplaces_unit_4,
      :fireplaces_unit_5,
      :fireplaces_unit_6,
      :franchise,
      :free_and_clear,
      :furnished,
      :pad_ready,
      :power_service_in_amps,
      :publish_to_internet,
      :range_oven_unit_1,
      :range_oven_unit_2,
      :range_oven_unit_3,
      :range_oven_unit_4,
      :range_oven_unit_5,
      :range_oven_unit_6,
      :refrigerator_unit_1,
      :refrigerator_unit_2,
      :refrigerator_unit_3,
      :refrigerator_unit_4,
      :refrigerator_unit_5,
      :refrigerator_unit_6,
      :remodeled_updated,
      :senior_exemption,
      :show_address_to_public,
      :show_map_link_to_public,
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
      :approved_accessory_dwelling,
      :architecture,
      :barn_type,
      :basement,
      :bonus_room_location,
      :building_condition,
      :cats_and_dogs,
      :den_or_office_location,
      :electricity,
      :entry_location,
      :environmental_cert,
      :extra_finished_room_location,
      :family_room_location,
      :farm_type,
      :form_17,
      :foundation,
      :gas,
      :kitchen_location,
      :kitchen_with_eating_space_location,
      :lease_terms,
      :leased_terms,
      :living_room_location,
      :loading,
      :lot_topography_vegetation,
      :major_type_of_business,
      :master_bedroom_location,
      :possession,
      :property_type,
      :rec_room_location,
      :status,
      :style,
      :terms_and_conditions,
      :third_party_approval_required,
      :type_of_fireplace,
      :utility_room_location,
      :water_source,
    ]

    MULTI_ENCODED_ATTRIBUTES = [
      :additional_finished_rooms,
      :amenities,
      :appliance_hookups,
      :appliances_provided,
      :appliances_that_stay,
      :assessment_fees,
      :barn_features,
      :building_information,
      :common_features,
      :community_features,
      :dining_room_location,
      :documents_provided,
      :energy_source,
      :equipment_included,
      :exterior,
      :features,
      :fence,
      :floor_covering,
      :general_zoning_classification,
      :heating_and_cooling,
      :home_owner_dues_include,
      :improvements,
      :included_in_rent,
      :interior_features,
      :irrigation_source,
      :irrigation_type,
      :leased_equipment,
      :leased_items,
      :licenses,
      :livestock_type,
      :location,
      :lot_details,
      :manufactured_home_features,
      :move_in_funds_required,
      :new_construction,
      :other_rooms,
      :outbuildings,
      :park_amenities,
      :parking_type,
      :parking_type,
      :parking_types,
      :pool,
      :potential_terms,
      :property_features,
      :real_property,
      :restrictions,
      :road_information,
      :roof,
      :sewer,
      :site_features,
      :soil_type,
      :space_rent_includes,
      :terms,
      :topography,
      :type_of_property,
      :unit_features,
      :view,
      :water,
      :waterfront,
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

        attr_accessor(*self.attributes)

        def self.find(conditions = {}, filters = [])
          if conditions.is_a?(Hash)
            conditions.merge!(:property_type => options[:property_type])
          end
          super(conditions, filters)
        end
      end
    end

#    BOOLEAN_ATTRIBUTES.each do |method|
#      define_method method do
#        case instance_variable_get("@#{method}")
#        when 'Y' then true
#        when 'N' then false
#        end
#      end
#      alias_method "#{method}?", method
#    end

  end
end
